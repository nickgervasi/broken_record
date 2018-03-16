module BrokenRecord
  module Aggregators
    class ResultAggregator
      def initialize
        @aggregated_results = {}
        patch_active_record_errors!
      end

      def add_result(result)
        job_class = result.job.klass
        if @aggregated_results[job_class]
          raise 'Why are we adding multiple results for a single class?'
        end
        @aggregated_results[job_class] = result
      end

      def report_job_start
        # No-op: Define in subclass
      end

      def report_results(klass)
        # No-op: Define in subclass
      end

      def report_final_results
        # No-op: Define in subclass
      end

      def success?
        total_error_count == 0
      end

      def count(klass)
        results_for_class(klass).errors.count
      end

      def exit_program
        exit(success? ? 0 : 1)
      end

      private

      def total_error_count
        errors.count
      end

      def error_ids_for(klass)
        results_for_class(klass).errors.map(&:id).compact
      end

      def all_classes
        @aggregated_results.keys
      end

      def all_results
        @aggregated_results.values.flatten
      end

      def errors
        all_results.flat_map(&:errors)
      end

      def errors_for(klass)
        results_for_class(klass).errors
      end

      def duration(klass)
        start_time = results_for_class(klass).start_time
        end_time = results_for_class(klass).end_time
        (end_time - start_time).round(3)
      end

      def app_name
        Rails.application.class.parent_name
      end

      def results_for_class(klass)
        @aggregated_results[klass]
      end

      def patch_active_record_errors!
        require 'broken_record/patches/active_model_errors'
      end
    end
  end
end
