module BrokenRecord
  class JobResult
    attr_reader :start_time, :end_time, :job, :normalized_errors

    def initialize(job)
      @job = job
      @normalized_errors = []
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def add_error(id: nil, error_type:, message:)
      @normalized_errors << { id: id, message: message, error_type: error_type }
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
