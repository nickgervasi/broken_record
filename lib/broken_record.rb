require "broken_record/version"
require "broken_record/config"
require "broken_record/scanner"
require "broken_record/railtie" if defined? Rails::Railtie

module BrokenRecord
  extend self

  def configure
    yield BrokenRecord::Config
  end
end

BrokenRecord.configure do |config|
  config.classes_to_skip = []
end
