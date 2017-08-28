require 'broken_record/patches/active_model_validators'
require "broken_record/version"
require "broken_record/config"
require "broken_record/scanner"
require "broken_record/railtie" if defined? Rails::Railtie
require "broken_record/job_result"

module BrokenRecord
  extend self

  def configure
    yield BrokenRecord::Config

    unless BrokenRecord::Config.default_scopes.nil? || BrokenRecord::Config.default_scopes.count == 0
      ActiveSupport::Deprecation.warn("default_scopes are deprecated and will be removed in the next major version.")
      BrokenRecord::Config.model_includes = BrokenRecord::Config.default_scopes
      BrokenRecord::Config.model_conditions = BrokenRecord::Config.default_scopes
    end

    unless BrokenRecord::Config.aggregator_class.nil?
      warn_class_string_deprecation('aggregator_class')
      ActiveSupport::Deprecation.warn(
        "aggregator_class is deprecated and will be removed in the next major version.
        Please use aggregator, e.g. :console"
      )
      BrokenRecord::Config.aggregator = get_symbol_from_klass_string(BrokenRecord::Config.aggregator_class)
    end

    unless BrokenRecord::Config.multi_aggregator_classes.nil? || BrokenRecord::Config.multi_aggregator_classes.count == 0
      ActiveSupport::Deprecation.warn(
        "multi_aggregator_classes is deprecated and will be removed in the next major version.
        Please use multi_aggregators, e.g. [:console, :bugsnag]"
      )
      BrokenRecord::Config.multi_aggregators = BrokenRecord::Config.multi_aggregator_classes.map do |klass_string|
        get_symbol_from_klass_string(klass_string)
      end
    end

    unless BrokenRecord::Config.job_scheduler_class.nil?
      ActiveSupport::Deprecation.warn(
        "job_scheduler_class is deprecated and will be removed in the next major version.
        Please use job_scheduler, e.g. :parallel_job"
      )
      BrokenRecord::Config.job_scheduler = get_symbol_from_klass_string(BrokenRecord::Config.job_scheduler_class)
    end
  end

  private

  def get_symbol_from_klass_string(klass_string)
    klass_base_name = klass_string.split("::")[-1]
    klass_base_name
      .gsub('Aggregator', '')
      .gsub('Scheduler', '')
      .to_sym
  end
end
