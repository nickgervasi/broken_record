## v0.0.1

* Initial release

## v0.0.2

* Initialize BrokenRecord::Config.before_scan_callbacks
* Add 'require' statements needed in lazy environments

## v0.0.3

* Allow setting a per-model default scope

## v0.0.5

* Show per-model test duration in log output

## v0.0.6

* Allow classes_to_skip and default_scope keys to be strings as well as classes

## v0.0.7

* Make BrokenRecord work with colorize >= 0.5.8
* Allow BrokenRecord::Scanner to be used programmatically (i.e. from rails console)
* Remove assumption that all models are in app/models/**/*.rb
* Show backtrace when exception occurs during scan
* Change parallelization strategy to better distribute load across cores
* Add an after_fork hook
