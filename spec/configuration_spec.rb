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

  it "defines turbosprockets_enabled" do
    expect(@configuration.fetch(:turbosprockets_enabled)).to be_false
  end

  it "defines turbosprockets_backup_dir" do
    dir = 'public/.assets'
    expect(@configuration.fetch(:turbosprockets_backup_dir)).to eq(dir)
  end

  it "defines rsync_cmd" do
    expect(@configuration.fetch(:rsync_cmd)).to eq('rsync -av')
  end

  it "performs deploy:assets:prepare before deploy:assets:precompile" do
    expect(@configuration).to callback('deploy:assets:prepare').
      before('deploy:assets:precompile')
  end

  it "performs deploy:assets:cleanup after deploy:assets:precompile" do
    expect(@configuration).to callback('deploy:assets:cleanup').
      after('deploy:assets:precompile')
  end
end
