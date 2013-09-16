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

  gem.add_dependency 'capistrano'

  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ['lib']
end
