module BrokenRecord
  module Aggregators
    class ConsoleAggregator < ResultAggregator
      def report_results(klass, logger: $stdout)
        super(klass)
        class_errors = errors_for(klass)
        invalid_model_ids = error_ids_for(klass).uniq
        duration = duration(klass)

        logger.print "Running validations for #{klass}... ".ljust(70)
        success = class_errors.empty?
        report_result_header(logger, success, duration)
        report_class_errors(logger, klass, class_errors, invalid_model_ids, duration) if class_errors.any?
      end

      def report_final_results(logger: $stdout)
        if total_error_count == 0
          logger.puts "\nAll models validated successfully.".green
        else
          logger.puts "\n#{total_error_count} errors were found while running validations.".red
        end
      end

      private

      def report_result_header(logger, success, duration)
        if success
          logger.print '[PASS]'.green
        else
          logger.print '[FAIL]'.red
        end

        report_duration(logger, duration)
      end

      def report_class_errors(logger, klass, class_errors, invalid_model_ids, duration)
        default_result_count = BrokenRecord::Config.default_result_count

        displayed_validation_errors_count = [class_errors.count, default_result_count].min

        logger.puts "#{class_errors.length} errors were found on #{invalid_model_ids.count} models while running validations for #{klass}\n"
        logger.puts "Invalid ids: #{invalid_model_ids.inspect}"
        logger.puts "First #{displayed_validation_errors_count} errors"

        formatted_errors = class_errors.map do |reportable_error|
          id = reportable_error.id
          message = "    Invalid record in #{klass.name} id=#{id}.\n        "
          message << reportable_error.message
          message.red
        end

        formatted_errors = formatted_errors[0...displayed_validation_errors_count].join("\n")

        logger.puts formatted_errors
      end

      def report_duration(logger, duration)
        logger.print "  (#{duration}s)\n"
      end
    end
  end
end
