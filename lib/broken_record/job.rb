require 'broken_record/job_result'

module BrokenRecord
  class Job
    attr_accessor :klass, :index, :parallelization

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
            models_with_includes.where("#{klass.table_name}.#{primary_key}" => id_batch).each do |r|
              begin
                if !r.valid?
                  message = "    Invalid record in #{klass} id=#{r.id}."
                  r.errors.each { |attr,msg| message <<  "\n        #{attr} - #{msg}" } unless compact_output
                  result.add_error(
                    id: r.id,
                    error_type: 'Invalid Record',
                    message: message
                  )
                end
              rescue Exception => e
                result.add_error(
                  id: r.id,
                  error_type: 'Validation Exception',
                  message: serialize_exception("    Exception for record in #{klass} id=#{r.id} ", e, compact_output)
                )
              end
            end
          end
        rescue Exception => e
          result.add_error(
            error_type: 'Loading Exception',
            message: serialize_exception("    Exception while trying to load models for #{klass}.", e, compact_output)
          )
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
      records_per_group = (models_with_conditions.count / parallelization.to_f).ceil
      scope = models_with_conditions.offset(records_per_group * index)
      scope.limit(records_per_group).pluck(primary_key)
    end

    def models_with_includes
      apply_scope(BrokenRecord::Config.model_includes)
    end

    def models_with_conditions
      apply_scope(BrokenRecord::Config.model_conditions)
    end

    def apply_scope(scopes)
      applicable_scope = scopes[klass] || scopes[klass.to_s]
      if applicable_scope
        klass.instance_exec &applicable_scope
      else
        klass.unscoped
      end
    end
  end
end
