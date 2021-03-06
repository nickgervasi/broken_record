require 'broken_record/job_result'

module BrokenRecord
  class Job
    JOBS_PER_PROCESSOR = 1

    attr_accessor :klass, :index

    def self.jobs_per_class
      JOBS_PER_PROCESSOR * Parallel.processor_count
    end

    def self.build_jobs(classes)
      jobs = []
      classes.each do |klass|
        jobs_per_class.times do |index|
          jobs << Job.new(:klass => klass, :index => index)
        end
      end
      jobs
    end

    def initialize(options)
      options.each { |k, v| send("#{k}=", v) }
    end

    def perform
      BrokenRecord::JobResult.new(self).tap do |result|
        result.start_timer

        begin
          batch_size = 1000
          compact_output = BrokenRecord::Config.compact_output
          record_ids.each_slice(batch_size) do |id_batch|
            model_scope.where("#{klass.table_name}.#{primary_key}" => id_batch).each do |r|
              begin
                if !r.valid?
                  message = "    Invalid record in #{klass} id=#{r.id}."
                  r.errors.each { |attr,msg| message <<  "\n        #{attr} - #{msg}" } unless compact_output
                  result.add_error message
                end
              rescue Exception => e
                result.add_error serialize_exception("    Exception for record in #{klass} id=#{r.id} ", e, compact_output)
              end
            end
          end
        rescue Exception => e
          result.add_error serialize_exception("    Exception while trying to load models for #{klass}.", e, compact_output)
        end

        result.stop_timer
      end
    end

    private

    def serialize_exception(message, e, compact_output)
      message << "- #{e}.\n" << e.backtrace.map { |line| "        #{line}"}.join("\n") unless compact_output
      message
    end

    def primary_key
      klass.primary_key
    end

    def record_ids
      records_per_group = (model_scope.count / self.class.jobs_per_class.to_f).ceil
      scope = model_scope.offset(records_per_group * index)
      scope.limit(records_per_group).pluck(primary_key)
    end

    def model_scope
      default_scope = BrokenRecord::Config.default_scopes[klass] || BrokenRecord::Config.default_scopes[klass.to_s]

      if default_scope
        klass.instance_exec &default_scope
      else
        klass.unscoped
      end
    end
  end
end
