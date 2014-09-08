require 'spec_helper'

describe Capistrano::LocalPrecompile, "integration" do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.load do
      def rails_env; 'production'; end
      def rake; 'rake'; end
      def asset_env; "RAILS_GROUPS=assets"; end
    end
    Capistrano::LocalPrecompile.load_into(@configuration)
  end

  describe 'cleanup task' do
    it 'removes the asset files from public/assets' do
      expect(@configuration).to receive(:run_locally).
        with('rm -rf public/assets')

      @configuration.find_and_execute_task('deploy:assets:cleanup')
    end
  end

  describe 'prepare task' do
    it 'invokes the precompile command' do
      expect(@configuration).to receive(:run_locally).
        with('RAILS_ENV=production RAILS_GROUPS=assets rake assets:precompile').once

      @configuration.find_and_execute_task('deploy:assets:prepare')
    end
  end

  describe 'remove manifest task' do
    it 'invokes the precompile command' do
      expect(@configuration).to receive(:run).
        with('rm -f public/assets/manifest*.json').once

      @configuration.find_and_execute_task('deploy:assets:remove_manifest')
    end
  end

  describe 'precompile task' do
    let(:servers) { %w(10.0.1.1 10.0.1.2) }

    before do
      allow(@configuration).to receive(:run_locally).
        with("ls public/assets/manifest*").and_return("public/assets/manifest.yml").once
      allow(@configuration).to receive(:run_locally).
        with('RAILS_ENV=production RAILS_GROUPS=assets rake assets:precompile').once
      allow(@configuration).to receive(:run_locally).
        with('rm -rf public/assets').once


      allow(@configuration).to receive(:user).and_return('root')
      allow(@configuration).to receive(:assets_role).and_return('app')
      allow(@configuration).to receive(:find_servers).and_return(servers)
      allow(@configuration).to receive(:release_path).and_return('/tmp')
    end

    it 'rsyncs the local asset files to the server' do
      expect(@configuration).to receive(:run_locally).with(/rsync -av/).exactly(4).times

      @configuration.find_and_execute_task('deploy:assets:precompile')
    end
  end
end
