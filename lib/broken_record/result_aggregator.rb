module BrokenRecord
  class ResultAggregator
    def initialize
      @total_errors = 0
      @aggregated_results = {}
    end

    def add_result(result)
      @aggregated_results[result.job.klass] ||= []
      @aggregated_results[result.job.klass] << result
    end

    def count(klass)
      @aggregated_results[klass].count
    end

    def report_results(klass)
      @total_errors += all_errors(klass).count
    end

    def report_final_results
      # No-op: Define in subclass
    end

    def success?
      @total_errors == 0
    end

    private

    def all_errors(klass)
      @aggregated_results[klass].map(&:errors).flatten.reduce(&:merge)
    end

    def duration(klass)
      start_time = @aggregated_results[klass].map(&:start_time).min
      end_time = @aggregated_results[klass].map(&:end_time).max
      (end_time - start_time).round(3)
    end

    def app_name
      Rails.application.class.parent_name
    end
  end
end
