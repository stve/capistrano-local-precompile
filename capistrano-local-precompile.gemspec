# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name        = 'capistrano-local-precompile'
  gem.version     = '1.1.4'
  gem.homepage    = 'https://github.com/spagalloco/capistrano-local-precompile'

  gem.author      = "Steve Agalloco, Tom Caflisch"
  gem.email       = 'steve.agalloco@gmail.com, tomcaflisch@gmail.com'
  gem.description = 'Local asset-pipeline precompilation for Capstrano'
  gem.summary     = gem.description

  gem.license     = 'MIT'

  gem.add_dependency 'capistrano', '>=3.8'

  gem.files = %w(.yardopts LICENSE.md README.md Rakefile capistrano-local-precompile.gemspec)
  gem.files += Dir.glob("lib/**/*.rb")
  gem.files += Dir.glob("spec/**/*")

  gem.test_files = Dir.glob("spec/**/*")

  gem.require_paths = ['lib']
end
