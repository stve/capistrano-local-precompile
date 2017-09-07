require 'capistrano/rails/assets'

namespace :load do
  task :defaults do
    set :precompile_env,   fetch(:rails_env) || 'production'
    set :assets_dir,       "public/assets"
    set :packs_dir,        "public/packs"    
    set :rsync_cmd,        "rsync -av --delete"

    after "bundler:install", "deploy:assets:prepare"
    #before "deploy:assets:symlink", "deploy:assets:remove_manifest"
    after "deploy:assets:prepare", "deploy:assets:cleanup"
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
      run_locally do
        with rails_env: fetch(:precompile_env) do
          execute "rm -rf", fetch(:assets_dir)
        end
      end
    end

    desc "Actually precompile the assets locally"
    task :prepare do
      run_locally do
        with rails_env: fetch(:precompile_env) do
          execute "rake assets:clean"
          execute "rake assets:precompile"
        end
      end
    end

    desc "Performs rsync to app servers"
    task :precompile do
      on roles(fetch(:assets_role)) do

        local_manifest_path = run_locally "ls #{assets_dir}/manifest*"
        local_manifest_path.strip!

        run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{user}@#{server}:#{release_path}/#{fetch(:assets_dir)}/"
        run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:packs_dir)}/ #{user}@#{server}:#{release_path}/#{fetch(:packs_dir)}/"  #TODO: Check if exists      
        run_locally "#{fetch(:rsync_cmd)} ./#{local_manifest_path} #{user}@#{server}:#{release_path}/assets_manifest#{File.extname(local_manifest_path)}"
      end
    end
  end
end
