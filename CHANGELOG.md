### unreleased:

- Enable configuration of `:assets_release_path` so that it can easily
  be changed to `:shared_path` or similar

# 1.1.4 / 2018-09-04
## Fixed
- 2nd argument being ignored on OSX

# 1.1.3 / 2018-07-02
## Removed
- Rails capistrano assets dependency

# 1.1.2 / 2018-05-31
## Added
- Cleanup packs directory when complete

# 1.1.1 / 2018-04-21
## Added
- Support for capistrano 3.8+

# 1.1.0 / 2017-09-18
## Added
- Support for [Webpacker](https://github.com/rails/webpacker ) gem

# 0.1.0 / 2017-05-20

* [ENHANCEMENT] Compatible with Capistrano v3

# 0.0.5 / ?

* ?

# 0.0.4 / 2014-03-27

* [BUGFIX] Tighten capistrano dependency to avoid issues with capistrano 3.0.0

# 0.0.3 / 2014-03-07

* [BUGFIX] Fix issue where capistrano clean_expired deletes all assets (#4)
* [BUGFIX] Use proper rails_env when compiling assets
* [BUGFIX] Explicitly declare MIT license

# 0.0.2 / 2013-10-04

* [BUGFIX] Fix rsync issue requing extra backslash

# 0.0.1 / 2013-09-15

* Initial version
