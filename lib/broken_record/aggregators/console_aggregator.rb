module BrokenRecord
  module Aggregators
    class ConsoleAggregator < ResultAggregator
      def report_results(klass, logger: $stdout)
        super(klass)

        default_result_count = BrokenRecord::Config.default_result_count

        class_errors = errors_for(klass)
        error_ids_for = error_ids_for(klass)
        duration = duration(klass)

        formatted_errors = class_errors.map do |reportable_error|
          id = reportable_error.id
          message = "    Invalid record in #{klass.name} id=#{id}.\n        "
          message << reportable_error.message
          message.red
        end

        formatted_errors = formatted_errors[0...default_result_count].join("\n")

        logger.print "Running validations for #{klass}... ".ljust(70)
        if class_errors.empty?
          logger.print '[PASS]'.green
        else
          logger.print '[FAIL]'.red
        end
        logger.print "  (#{duration}s)\n"

        error_count = class_errors.length
        displayed_validation_errors_count = [error_count, default_result_count].min
        if class_errors.any?
          logger.puts "#{class_errors.length} errors were found while running validations for #{klass}\n"
          logger.puts "Invalid ids: #{error_ids_for.inspect}"
          logger.puts "Validation errors on first #{displayed_validation_errors_count} invalid models"
          logger.puts formatted_errors
        end
      end

      def report_final_results(logger: $stdout)
        if total_error_count == 0
          logger.puts "\nAll models validated successfully.".green
        else
          logger.puts "\n#{total_error_count} errors were found while running validations.".red
        end
      end
    end
  end
end
