module BrokenRecord
  class ConsoleAggregator < ResultAggregator
    def report_results(klass)
      super(klass)

      result_count = BrokenRecord::Config.default_result_count

      all_errors = all_errors(klass)
      duration = duration(klass)

      print "Validating model #{klass}... ".ljust(70)
      if all_errors.empty?
        print '[PASS]'.green
      else
        print '[FAIL]'.red
      end
      print "  (#{duration}s)\n"

      if all_errors.any?
        puts "#{all_errors.length} errors were found while running validations for #{klass}\n"
        puts "Invalid ids: #{all_errors.keys.inspect}"
        puts "Validation errors on first #{result_count} invalid models"
        puts all_errors.values[0..result_count-1].join
      end
    end

    def report_final_results
      if @total_errors == 0
        puts "\nAll models validated successfully.".green
      else
        puts "\n#{@total_errors} errors were found while running validations.".red
      end
    end

  end
end
