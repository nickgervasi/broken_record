require 'parallel'

module BrokenRecord
  module Schedulers
    class ExternalJobScheduler < JobScheduler
      def run
        finish_callback = proc do |_, _, result|
          if result.is_a? BrokenRecord::JobResult
            result_aggregator.add_result(result)
            result_aggregator.report_results(result.job.klass)
          end
        end

        result_aggregator.report_job_start

        # Don't run in parallel, just utilize the callback functionality of the parallel gem
        Parallel.each(jobs, { finish: finish_callback, in_processes: 0 }) do |job|
          job.perform
        end
      end

      private
      def jobs
        jobs = []
        classes.each.with_index do |klass, i|
          jobs << job_type.new(klass: klass) if i % options[:jobs_total] == options[:job_index]
        end
        jobs
      end
    end
  end
end
