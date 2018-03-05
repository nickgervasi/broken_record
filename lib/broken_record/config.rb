module BrokenRecord
  module Config
    extend self
    attr_accessor :classes_to_skip, :before_scan_callbacks, :after_fork_callbacks,
                  :default_scopes, :model_includes, :model_conditions, :default_result_count,
                  :compact_output, :aggregator_class, :job_scheduler_class,
                  :job_scheduler_options, :slack_options, :datadog_api_key,
                  :multi_aggregator_classes, :bugsnag_api_key, :prioritized_models,
                  :aggregator, :multi_aggregators, :job_scheduler

    self.before_scan_callbacks = []
    self.after_fork_callbacks = []
    self.classes_to_skip = []
    self.default_scopes = {}
    self.model_includes = {}
    self.model_conditions = {}
    self.default_result_count = 5
    self.compact_output = false
    self.aggregator = :console
    self.multi_aggregators = []
    self.job_scheduler = :parallel_job
    self.job_scheduler_options = {}
    self.slack_options = {}
    self.datadog_api_key = ENV['DATADOG_API_KEY']
    self.bugsnag_api_key = ENV['BUGSNAG_API_KEY']
    self.prioritized_models = []

    def before_scan(&block)
      self.before_scan_callbacks << block
    end

    def after_fork(&block)
      self.after_fork_callbacks << block
    end

    def get_configured_class(class_symbol, class_type)
      titleized_class = class_type.to_s.titlecase
      "BrokenRecord::#{titleized_class}s::#{class_symbol.to_s.classify}#{titleized_class}".constantize
    end
  end
end
