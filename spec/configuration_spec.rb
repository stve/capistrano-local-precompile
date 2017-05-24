require 'spec_helper'

describe Capistrano::LocalPrecompile, "configuration" do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.load do
      def rails_env; 'production'; end
      def rake; 'rake'; end
      def asset_env; "RAILS_GROUPS=assets"; end
    end
    Capistrano::LocalPrecompile.load_into(@configuration)
  end

  it "defines precompile_env" do
    expect(@configuration.fetch(:precompile_env)).to eq('production')
  end

  it "defines precompile_cmd" do
    cmd = 'RAILS_ENV=production RAILS_GROUPS=assets rake assets:precompile'
    expect(@configuration.fetch(:precompile_cmd)).to eq(cmd)
  end

  it "defines cleanexpired_cmd" do
    cmd = 'RAILS_ENV=production RAILS_GROUPS=assets rake assets:clean_expired'
    expect(@configuration.fetch(:cleanexpired_cmd)).to eq(cmd)
  end

  it "defines assets_dir" do
    expect(@configuration.fetch(:assets_dir)).to eq('public/assets')
  end

  it "defines rsync_cmd" do
    expect(@configuration.fetch(:rsync_cmd)).to eq('rsync -av --delete')
  end

  it "performs deploy:assets:prepare before deploy:assets:precompile" do
    expect(@configuration).to callback('deploy:assets:prepare').
      before('deploy:assets:precompile')
  end

  it "performs deploy:assets:remove before deploy:assets:precompile" do
    expect(@configuration).to callback('deploy:assets:remove').
                                  before('deploy:assets:symlink')
  end

  it "performs deploy:assets:cleanup after deploy:assets:precompile" do
    expect(@configuration).to callback('deploy:assets:cleanup').
      after('deploy:assets:precompile')
  end

  it "performs deploy:assets:remove_manifest before deploy:assets:symlink" do
    expect(@configuration).to callback('deploy:assets:remove_manifest').
                                  before('deploy:assets:symlink')
  end
end
