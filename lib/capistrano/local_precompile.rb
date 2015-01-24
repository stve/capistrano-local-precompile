require 'capistrano'

module Capistrano
  module LocalPrecompile

    def self.load_into(configuration)
      configuration.load do

        set(:precompile_env)   { rails_env }
        set(:precompile_cmd)   { "RAILS_ENV=#{precompile_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile" }
        set(:cleanexpired_cmd) { "RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:clean_expired" }
        set(:assets_dir)       { "public/assets" }
        set(:rsync_cmd)        { "rsync -av" }

        before "deploy:assets:precompile", "deploy:assets:prepare"
        before "deploy:assets:symlink", "deploy:assets:remove_manifest"

        after "deploy:assets:precompile", "deploy:assets:cleanup"

        namespace :deploy do
          namespace :assets do

            desc "remove manifest file from remote server"
            task :remove_manifest do
              run "rm -f #{shared_path}/#{shared_assets_prefix}/manifest*"
            end

            task :cleanup, :on_no_matching_servers => :continue  do
              run_locally "rm -rf #{fetch(:assets_dir)}"
            end

            task :prepare, :on_no_matching_servers => :continue  do
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
