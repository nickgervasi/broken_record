# BrokenRecord
[![Build status](https://badge.buildkite.com/b2a7685afb59070c272eebf79d0763789896c627508e181a77.svg)](https://buildkite.com/gusto/broken-record)

Provides a rake task for scanning your ActiveRecord models and detecting validation errors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'broken_record'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install broken_record
```

## Usage

To scan all records of all models in your project:

```bash
rake broken_record:scan
```

If you want to scan all records of a specific model (e.g. the User model):

```bash
rake broken_record:scan[User]
```

You can also specify a list of models to scan:

```bash
rake broken_record:scan[Product,User]
```

## Configuration

BrokenRecord provides a configure method with multiple options.  Here's an example:

```ruby
BrokenRecord.configure do |config|
    # Skip the Foo and Bar models when scanning.
    config.classes_to_skip = [Foo, Bar]

    # Set a scope for which models should be validated
    config.default_scopes = { Foo => proc { with_bars } }

    # The follow block will be called before scanning your records.
    # This is useful for skipping validations you want to ignore.
    config.before_scan do
        User.skip_callback :validate, :before, :user_must_be_active
    end

    # BrokenRecord uses the parallelize gem to distribute work across
    # multiple cores. The following block will be called every time
    # the process is forked (useful for re-establishing connections).
    config.after_fork do
      Rails.cache.reconnect if Rails.cache.respond_to? :reconnect
    end

    # The compact_output option will report the ids of invalid records
    # but it will omit any relevant messages or backtraces.
    config.compact_output = true
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
