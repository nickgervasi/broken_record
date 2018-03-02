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

      def method_missing(method, *args, &block)
        @aggregators.map do |a|
          a.send(method, *args, &block)
        end
      end

    end
  end
end
