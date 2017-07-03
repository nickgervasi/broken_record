require 'broken_record/patches/active_model_validators'
require "broken_record/version"
require "broken_record/config"
require "broken_record/scanner"
require "broken_record/railtie" if defined? Rails::Railtie

module BrokenRecord
  extend self

  def configure
    yield BrokenRecord::Config

    unless BrokenRecord::Config.default_scopes.blank?
      ActiveSupport::Deprecation.warn("default_scopes are deprecated and will be removed in the next major version.")
      BrokenRecord::Config.model_includes = BrokenRecord::Config.default_scopes
      BrokenRecord::Config.model_conditions = BrokenRecord::Config.default_scopes
    end
  end
end

BrokenRecord.configure do |config|
  config.classes_to_skip = []
end
