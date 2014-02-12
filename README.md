# Capistrano Local Precompile

If your Rails apps are anything like mine, one of the slowest parts of your deployment is waiting for asset pipeline precompilation. It's sometimes so slow, it's painful. So I went searching for some solutions. [turbo-sprockets](https://github.com/ndbroadbent/turbo-sprockets-rails3) helped, but it's not a silver bullet.  This gem isn't a silver bullet either, but it can help.  Capistrano Local Precompile takes a different approach. It builds your assets locally and rsync's them to your web server(s).

*Note: This gem is not yet compatible with Capistrano 3.*

## Usage

Add capistrano-local-precompile to your Gemfile:

```ruby
group :development do
  gem 'capistrano-local-precompile', require: false
end
```

Then add the following line to your `deploy.rb`:

```ruby
require 'capistrano/local_precompile'
```

If you are using turbo-sprockets, just set it to enabled. Your asset will still compile locally, but they'll use turbosprockets to do so:

```ruby
set :turbosprockets_enabled, true
```

If you don't want to grant access to production's database from outside you can add:

```ruby
set :use_local_env, true
```
and local precompile will happen with a custom environment. For example if your production's environment is setup as 'production', enabling :use_local_env precompile will happen with 'production-local' environment.
To make it work you will have to define the new environment but it's worth to don't open your production's database to everyone.

Here's the full set of configurable options:

```ruby
set :precompile_cmd             # default: bundle exec rake assets:precompile
set :assets_dir                 # default: "public/assets"
set :rsync_cmd                  # default: "rsync -av"

set :turbosprockets_enabled     # default: false
set :turbosprockets_backup_dir  # default: "public/.assets"
set :cleanexpired_cmd           # default: bundle exec rake assets:clean_expired
set :use_local_env              # default: false
```

## Acknowledgement

This gem is derived from gists by [uhlenbrock][] and [keighl][].

[uhlenbrock]: https://gist.github.com/uhlenbrock/1477596
[keighl]: https://gist.github.com/keighl/4338134

## Contributing

Pull requests welcome: fork, make a topic branch, commit (squash when possible) *with tests* and I'll happily consider.

## Copyright

Copyright (c) 2013 Steve Agalloco. See [LICENSE](LICENSE.md) for detail
