module BrokenRecord
  class MultiAggregator

    def initialize()
      @aggregators = BrokenRecord::Config.multi_aggregator_classes.map do |aggregator_class|
        aggregator_class.constantize.new
      end
    end

    def count(klass)
      @aggregators.first.count(klass)
    end

    def success?
      @aggregators.first.success?
    end

    def method_missing(method, *args, &block)
      @aggregators.map do |a|
        a.send(method, *args, &block)
      end
    end

  end
end
