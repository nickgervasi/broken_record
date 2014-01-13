# BrokenRecord

Provides a rake task for scanning your ActiveRecord models and detecting validation errors.

## Installation

Add this line to your application's Gemfile:

    gem 'broken_record'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install broken_record

## Usage

To scan all records of all models in your project:

    rake broken_record:scan

If you want to scan all records of a specific model (e.g. the User model)

    rake broken_record:scan[User]

## Configuration

BrokenRecord provides a configure method with two options.  Here's an example:

    BrokenRecord.configure do |config|
        # Skip the Foo and Bar models when scanning.
        config.classes_to_skip = [Foo, Bar]

        # BrokenRecord will call the block provided in before_scan before scanning
        # your records.  This is useful for skipping validations you want to ignore.
        config.before_scan do
            User.skip_callback :validate, :before, :user_must_be_active
        end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
