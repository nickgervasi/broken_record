require 'parallel'

module BrokenRecord
  module Schedulers
    class ParallelJobScheduler < JobScheduler
      JOBS_PER_PROCESSOR = 1

      def run
        finish_callback = proc do |_, _, result|
          if result.is_a? BrokenRecord::JobResult
            result_aggregator.add_result(result)
            result_aggregator.report_results(result.job.klass)
          end
        end

        result_aggregator.report_job_start

        Parallel.each(jobs, { finish: finish_callback }) do |job|
          ActiveRecord::Base.connection.reconnect!
          BrokenRecord::Config.after_fork_callbacks.each { |callback| callback.call }
          job.perform
        end
      end

      private

      def jobs
        classes.map { |klass| job_type.new(klass: klass) }
      end
    end
  end
end
