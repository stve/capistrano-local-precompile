# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-local-precompile/version'

Gem::Specification.new do |gem|
  gem.name        = 'capistrano-local-precompile'
  gem.version     = CapistranoLocalPrecompile::VERSION
  gem.homepage    = 'https://github.com/spagalloco/capistrano-local-precompile'

  gem.author      = "Steve Agalloco"
  gem.email       = 'steve.agalloco@gmail.com'
  gem.description = 'Local asset-pipeline precompilation for Capstrano'
  gem.summary     = gem.description

  gem.license     = 'MIT'

  gem.add_dependency 'capistrano', '~> 2'

  gem.files = %w(.yardopts LICENSE.md README.md Rakefile capistrano-local-precompile.gemspec)
  gem.files += Dir.glob("lib/**/*.rb")
  gem.files += Dir.glob("spec/**/*")

  gem.test_files = Dir.glob("spec/**/*")

  gem.require_paths = ['lib']
end
