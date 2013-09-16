# coding: utf-8
unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_group 'Capistrano', 'lib/capistrano'
    add_group 'Specs', 'spec/*'
    add_filter '.bundle'
  end
end

require 'capistrano-local-precompile'
require 'rspec'
require 'capistrano-spec'

RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
