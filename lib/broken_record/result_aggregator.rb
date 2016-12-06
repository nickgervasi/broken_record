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
      result_count = BrokenRecord::Config.default_result_count

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

      if all_errors.any?
        print "#{all_errors.length} errors were found while running validations for #{klass}\n"
        print all_errors[0..result_count-1].join
      end
    end

    def report_final_results
      if @total_errors == 0
        puts "\nAll models validated successfully.".green
      else
        puts "\n#{@total_errors} errors were found while running validations.".red
      end
    end

    def success?
      @total_errors == 0
    end
  end
end
