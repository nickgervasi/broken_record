module BrokenRecord
  class JobResult
    attr_reader :start_time, :end_time, :job, :normalized_errors, :original_errors, :exceptions

    def initialize(job)
      @job = job
      @normalized_errors = []
      @original_errors = []
      @exceptions = []
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def add_error(id: nil, error_type:, message:, errors: nil, exception: nil)
      @normalized_errors << { id: id, message: message, error_type: error_type }
      @original_errors << [id, errors] if errors
      if exception
        exception_hash = {
          context: exception.backtrace.grep(Regexp.new(Rails.root.to_s))[0].gsub("#{Rails.root}/", ''),
          exception_class: exception.is_a?(Class) ? exception : exception.class,
          message: exception.message,
          source: exception.backtrace
        }
        @exceptions << [id, exception_hash]
      end
    end

    def errors
      @normalized_errors.map do |error|
        "#{error[:message].red}\n"
      end
    end

    def error_ids
      @normalized_errors.map do |error|
        error[:id]
      end.compact
    end
  end
end
