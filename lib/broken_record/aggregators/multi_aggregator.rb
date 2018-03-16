module BrokenRecord
  module Aggregators
    class MultiAggregator

      def initialize
        @aggregators = BrokenRecord::Config.multi_aggregators.map do |aggregator_symbol|
          BrokenRecord::Config.get_configured_class(aggregator_symbol, :aggregator).new
        end
      end

      def count(klass)
        @aggregators.first.count(klass)
      end

      def success?
        @aggregators.all?(&:success?)
      end

      def exit_program
        bugsnag_aggregator = @aggregators.find { |a| a.is_a?(BugsnagAggregator) }

        if bugsnag_aggregator
          bugsnag_aggregator.exit_program
        else
          exit(success? ? 0 : 1)
        end
      end

      def method_missing(method, *args, &block)
        @aggregators.map do |a|
          a.send(method, *args, &block)
        end
      end

    end
  end
end
