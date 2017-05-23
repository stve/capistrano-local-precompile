namespace :load do
  task :defaults do
    set(:precompile_env)   { rails_env }
    set(:precompile_cmd)   { "RAILS_ENV=#{precompile_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile" }
    set(:cleanexpired_cmd) { "RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:clean_expired" }
    set(:assets_dir)       { "public/assets" }
    set(:rsync_cmd)        { "rsync -av --delete" }

    before "deploy:compile_assets", "deploy:assets:prepare"
    #before "deploy:assets:symlink", "deploy:assets:remove_manifest"

    after "deploy:compile_assets", "deploy:assets:cleanup"
  end
end

namespace :deploy do
  # Clear existing task so we can replace it rather than "add" to it.
  Rake::Task["deploy:compile_assets"].clear

  namespace :assets do

    # desc "Remove manifest file from remote server"
    # task :remove_manifest do
    #   with rails_env: fetch(:assets_dir) do
    #     execute "rm -f #{shared_path}/#{shared_assets_prefix}/manifest*"
    #   end
    # end

    desc "Remove all local precompiled assets"
    task :cleanup do
      run_locally "rm -rf #{fetch(:assets_dir)}"
    end

    desc "Actually precompile the assets locally"
    task :prepare do
      run_locally do
        with rails_env: fetch(:stage) do
          execute "#{fetch(:precompile_cmd)}"
        end
      end
    end

    desc "Performs rsync to app servers"
    task :precompile do
      on roles(fetch(:assets_role)) do

        local_manifest_path = run_locally "ls #{assets_dir}/manifest*"
        local_manifest_path.strip!

        run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{user}@#{server}:#{release_path}/#{fetch(:assets_dir)}/"
        run_locally "#{fetch(:rsync_cmd)} ./#{local_manifest_path} #{user}@#{server}:#{release_path}/assets_manifest#{File.extname(local_manifest_path)}"
      end
    end
  end
end
