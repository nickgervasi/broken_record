
module BrokenRecord
  module Schedulers
    class JobScheduler
      attr_reader :classes, :result_aggregator, :options, :job_type

      ##
      # Creates a new JobScheduler
      #
      # @param classes [Array] - array of classes that can be validated by the specified job_type
      # @param result_aggregator [kind_of(ResultAggregator)] - the result aggregator that will log and report results
      # @param options [Hash] - hash of additional options to schedule the job with
      # @param job_type [Performable] - Any class that has a `perform` instance method that returns a `BrokenRecord::JobResult` (defaults to `BrokenRecord::Job`)
      #
      def initialize(classes, result_aggregator, options, job_type: Job)
        @classes = classes
        @result_aggregator = result_aggregator
        @options = options
        @job_type = job_type
      end

      def run
        raise 'This class must be subclassed'
      end
    end
  end
end
