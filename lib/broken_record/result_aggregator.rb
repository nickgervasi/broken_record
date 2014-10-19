module BrokenRecord
  class ResultAggregator
    def initialize
      @total_errors = 0
      @aggregated_results = {}
    end

    def add_result(result)
      @aggregated_results[result.job.klass] ||= []
      @aggregated_results[result.job.klass] << result

      if klass_done?(result.job.klass)
        report_results result.job.klass
      end
    end

    def report_final_results
      if @total_errors == 0
        puts "\nAll models validated successfully.".green
      else
        puts "\n#{@total_errors} errors were found while running validations.".red
        exit 1
      end
    end

    private

    def klass_done?(klass)
      @aggregated_results[klass].count == Job.jobs_per_class
    end

    def report_results(klass)
      all_errors = @aggregated_results[klass].map(&:errors).flatten
      start_time = @aggregated_results[klass].map(&:start_time).min
      end_time = @aggregated_results[klass].map(&:end_time).max
      duration = (end_time - start_time).round(3)

      @total_errors += all_errors.count

      print "Validating model #{klass}... ".ljust(70)
      if all_errors.empty?
        print '[PASS]'.green
      else
        print '[FAIL]'.red
      end
      print "  (#{duration}s)\n"
      print all_errors.join if all_errors.any?
    end
  end
end