require 'capistrano'

module Capistrano
  module LocalPrecompile

    def self.load_into(configuration)
      configuration.load do

        set(:precompile_cmd)   { "RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile" }
        set(:cleanexpired_cmd) { "RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:clean_expired" }
        set(:assets_dir)       { "public/assets" }

        set(:turbosprockets_enabled)    { false }
        set(:turbosprockets_backup_dir) { "public/.assets" }
        set(:rsync_cmd)                 { "rsync -av" }

        before "deploy:assets:precompile", "deploy:assets:prepare"
        before "deploy:assets:symlink", "deploy:assets:remove"

        after "deploy:assets:precompile", "deploy:assets:cleanup"

        namespace :deploy do
          namespace :assets do

            desc "remove manifest file from remote server"
            task :remove, roles: [:app, :web] do
              run "rm -f #{shared_path}/assets/manifest*.json"
            end

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
                run_locally "#{fetch(:cleanexpired_cmd)}"
              end
              run_locally "#{fetch(:precompile_cmd)}"
            end

            desc "Precompile assets locally and then rsync to app servers"
            task :precompile, :only => { :primary => true }, :on_no_matching_servers => :continue do

              local_manifest_path = run_locally "ls #{assets_dir}/manifest*"
              local_manifest_path.strip!

              servers = find_servers :roles => assets_role, :except => { :no_release => true }
              servers.each do |srvr|
                run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{user}@#{srvr}:#{release_path}/#{fetch(:assets_dir)}/"
                run_locally "#{fetch(:rsync_cmd)} ./#{local_manifest_path} #{user}@#{srvr}:#{release_path}/assets_manifest#{File.extname(local_manifest_path)}"
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
