require 'parallel'

module BrokenRecord
  class ExternalJobScheduler < JobScheduler
    def run
      finish_callback = proc do |_, _, result|
        if result.is_a? BrokenRecord::JobResult
          result_aggregator.add_result(result)
          result_aggregator.report_results(result.job.klass)
        end
      end

      # Don't run in parallel, just utilize the callback functionality of the parallel gem
      Parallel.each(jobs, { finish: finish_callback, in_processes: 0 }) do |job|
        job.perform
      end
    end

    private
    def jobs
      classes.map do |klass|
        Job.new(klass: klass, index: options[:job_index], parallelization: options[:jobs_total])
      end
    end
  end
end
