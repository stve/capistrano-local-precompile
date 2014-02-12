require 'capistrano'

module Capistrano
  module LocalPrecompile

    def self.load_into(configuration)
      configuration.load do
        set(:use_local_env)    { @use_local_env ? fetch(:use_local_env) : false}
        set(:precompile_cmd)   { "#{(fetch(:use_local_env) ? "RAILS_ENV=#{fetch(:rails_env)}-local " : '')}#{fetch(:bundle_cmd, "bundle")} exec rake assets:precompile" }
        set(:cleanexpired_cmd) { "#{(fetch(:use_local_env) ? "RAILS_ENV=#{fetch(:rails_env)}-local " : '')}#{fetch(:bundle_cmd, "bundle")} exec rake assets:clean_expired" }
        set(:assets_dir)       { "public/assets" }

        set(:turbosprockets_enabled)    { false }
        set(:turbosprockets_backup_dir) { "public/.assets" }
        set(:rsync_cmd)                 { "rsync -av" }

        before "deploy:assets:precompile", "deploy:assets:prepare"
        after "deploy:assets:precompile", "deploy:assets:cleanup"

        namespace :deploy do
          namespace :assets do

            task :cleanup, :on_no_matching_servers => :continue  do
              if fetch(:turbosprockets_enabled)
                run_locally "mv #{fetch(:assets_dir)} #{fetch(:turbosprockets_backup_dir)}"
              else
                run_locally "rm -rf #{fetch(:assets_dir)}"
              end
            end

            task :prepare, :on_no_matching_servers => :continue  do
              if fetch(:turbosprockets_enabled)
                run_locally "mkdir -p #{fetch(:turbosprockets_backup_dir)}"
                run_locally "mv #{fetch(:turbosprockets_backup_dir)} #{fetch(:assets_dir)}"
                run_locally "#{(fetch(:use_local_env) ? "RAILS_ENV=#{fetch(:rails_env)}-local " : '')}#{fetch(:cleanexpired_cmd)}"
              end
              run_locally "#{(fetch(:use_local_env) ? "RAILS_ENV=#{fetch(:rails_env)}-local " : '')}#{fetch(:precompile_cmd)}"
            end

            desc "Precompile assets locally and then rsync to app servers"
            task :precompile, :only => { :primary => true }, :on_no_matching_servers => :continue do
              servers = find_servers :roles => assets_role, :except => { :no_release => true }
              servers.each do |srvr|
                run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{user}@#{srvr}:#{release_path}/#{fetch(:assets_dir)}/"
              end
            end

          end
        end
      end
    end

  end
end

if Capistrano::Configuration.instance
  Capistrano::LocalPrecompile.load_into(Capistrano::Configuration.instance)
end
