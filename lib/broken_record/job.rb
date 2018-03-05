require 'broken_record/reportable_error'

module BrokenRecord
  class Job

    attr_accessor :klass

    def initialize(klass:)
      self.klass = klass
    end

    def perform
      BrokenRecord::JobResult.new(self).tap do |result|
        result.start_timer
        begin
          batch_size = 1000
          record_ids.each_slice(batch_size) do |id_batch|
            models_with_includes.where("#{klass.table_name}.#{primary_key}" => id_batch).each do |r|
              begin
                if !r.valid?
                  r.errors.error_mappings.each do |error_message, error_mapping|
                    stacktrace = Array(error_mapping[:source])

                    result.add_error(
                      BrokenRecord::ReportableError.new(r.id, error_message, error_mapping[:context], stacktrace)
                    )
                  end
                end
              rescue Exception => e
                stacktrace = BrokenRecord::ReportableError.prettify_stacktrace(e.backtrace, e)

                result.add_error(
                  BrokenRecord::ReportableError.new(r.id, "#{e.class} - #{e.message}", stacktrace[0], stacktrace)
                )
              end
            end
          end
        end

        result.stop_timer
      end
    end

    private

    def primary_key
      klass.primary_key
    end

    def record_ids
      models_with_conditions.pluck(primary_key)
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
