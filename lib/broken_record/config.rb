module BrokenRecord
  module Config
    extend self
    attr_accessor :classes_to_skip, :before_scan_callbacks, :after_fork_callbacks,
                  :default_scopes, :model_includes, :model_conditions, :default_result_count,
                  :compact_output, :aggregator_class, :job_scheduler_class,
                  :job_scheduler_options, :slack_options, :datadog_api_key,
                  :multi_aggregator_classes

    self.before_scan_callbacks = []
    self.after_fork_callbacks = []
    self.default_scopes = {}
    self.model_includes = {}
    self.model_conditions = {}
    self.default_result_count = 5
    self.compact_output = false
    self.aggregator_class = 'BrokenRecord::ConsoleAggregator'
    self.multi_aggregator_classes = []
    self.job_scheduler_class = 'BrokenRecord::ParallelJobScheduler'
    self.job_scheduler_options = {}
    self.slack_options = {}
    self.datadog_api_key = ENV['DATADOG_API_KEY']

    def before_scan(&block)
      self.before_scan_callbacks << block
    end

    def after_fork(&block)
      self.after_fork_callbacks << block
    end
  end
end
