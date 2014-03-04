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
                run_locally "#{fetch(:cleanexpired_cmd)}"
              end
              run_locally "#{fetch(:precompile_cmd)}"
            end

            desc "Precompile assets locally and then rsync to app servers"
            task :precompile, :only => { :primary => true }, :on_no_matching_servers => :continue do
              servers = find_servers :roles => assets_role, :except => { :no_release => true }
              servers.each do |srvr|
                run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{user}@#{srvr}:#{release_path}/#{fetch(:assets_dir)}/"
                run_locally "#{fetch(:rsync_cmd)} ./assets_manifest.* #{user}@#{srvr}:#{release_path}/"
              end

              # Sync manifest filenames across servers if our manifest has a random filename
              if shared_manifest_path =~ /manifest-.+\./
                run <<-CMD.compact
                  [ -e #{shared_manifest_path.shellescape} ] || mv -- #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* #{shared_manifest_path.shellescape}
                CMD
              end

              # Copy manifest to release root (for clean_expired task)
              run <<-CMD.compact
                cp -- #{shared_manifest_path.shellescape} #{current_release.to_s.shellescape}/assets_manifest#{File.extname(shared_manifest_path)}
              CMD
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
