# Capistrano Local Precompile

If your Rails apps are anything like mine, one of the slowest parts of your deployment is waiting for the asset pipeline to compile. It's so slow, it's painful. So I went searching for some solutions. [turbo-sprockets](https://github.com/ndbroadbent/turbo-sprockets-rails3) helped, but it's not a silver bullet.  This gem isn't a silver bullet either, but it can help.  Local Precompile builds your assets locally and rsync's them to your web servers.

## Usage

Add capistrano-local-precompile to your Gemfile:

    group :development do
      gem 'capistrano-local-precompile', require: false
    end

Then add the following line to your `deploy.rb`:

    require 'capistrano/local_precompile'

If you are using turbo-sprockets, just set it to enabled. Your asset will still compile locally, but they'll use turbosprockets to do so:

    set :turbosprockets_enabled, true

Here's the full set of configurable options:

    set :precompile_cmd             # default: bundle exec rake assets:precompile
    set :assets_dir                 # default: "public/assets"
    set :rsync_cmd                  # default: "rsync -av"

    set :turbosprockets_enabled     # default: false
    set :turbosprockets_backup_dir  # default: "public/.assets"
    set :cleanexpired_cmd           # default: bundle exec rake assets:clean_expired


## Acknowledgement

This gem is derived from gists by [uhlenbrock][] and [keighl][].

[uhlenbrock]: https://gist.github.com/uhlenbrock/1477596
[keighl]: https://gist.github.com/keighl/4338134

## Contributing

Pull requests welcome: fork, make a topic branch, commit (squash when possible) *with tests* and I'll happily consider.

## Copyright

Copyright (c) 2013 Steve Agalloco. See [LICENSE](LICENSE.md) for detail
