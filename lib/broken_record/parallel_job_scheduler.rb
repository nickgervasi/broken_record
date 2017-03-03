require 'parallel'

module BrokenRecord
  class ParallelJobScheduler < JobScheduler
    JOBS_PER_PROCESSOR = 1

    def run
      finish_callback = proc do |_, _, result|
        if result.is_a? BrokenRecord::JobResult
          result_aggregator.add_result(result)

          if result_aggregator.count(result.job.klass) == jobs_per_class
            result_aggregator.report_results(result.job.klass)
          end
        end
      end

      Parallel.each(jobs, { finish: finish_callback }) do |job|
        ActiveRecord::Base.connection.reconnect!
        BrokenRecord::Config.after_fork_callbacks.each { |callback| callback.call }
        job.perform
      end
    end

    private
    def jobs_per_class
      JOBS_PER_PROCESSOR * Parallel.processor_count
    end

    def jobs
      jobs = []
      classes.each do |klass|
        jobs_per_class.times do |index|
          jobs << Job.new(klass: klass, index: index, parallelization: jobs_per_class)
        end
      end
      jobs
    end
  end
end
