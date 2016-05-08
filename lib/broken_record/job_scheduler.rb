
module BrokenRecord
  class JobScheduler
    attr_reader :classes, :result_aggregator, :options

    def initialize(classes, result_aggregator, options)
      @classes = classes
      @result_aggregator = result_aggregator
      @options = options
    end

    def run
      raise 'This class must be subclassed'
    end
  end
end
