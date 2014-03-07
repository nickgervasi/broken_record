require 'colorize'
require 'tempfile'

module BrokenRecord
  class Logger

    # Static Methods

    def self.report_output(result, lock = nil)
      lock.flock File::LOCK_EX if lock
      $stdout.print result[:stdout]
      $stdout.flush
    ensure
      lock.flock File::LOCK_UN if lock
    end

    def self.report_results(test_results)
      total_errors = 0
      test_results.each { |result| total_errors += result[:error_count] }
      if total_errors == 0
        puts "\nAll models validated successfully.".green
      else
        puts "\n#{total_errors} errors were found while running validations.".red
        exit 1
      end
    end

    def self.parallel
      Tempfile.open 'broken_record_lock' do |lock|
        yield lock
      end
    end

    def self.log(model, &block)
      logger = new
      logger.start_log
      logger.log_header "Validating model #{model}... ".ljust(70)

      yield(logger)

      logger.log_result
      logger.result
    end

    # Instance Methods

    def initialize
      @header = ''
      @errors = []

      @stdout = ''
    end

    def log_header(header_message)
      @header = header_message
    end

    def start_log
      @start_time = Time.now
    end

    def log_error(message)
      @errors << "#{message.red}\n"
    end

    def log_result
      @stdout << @header

      if @errors.empty?
        @stdout << '[PASS]'.green
      else
        @stdout << '[FAIL]'.red
      end

      duration = (Time.now - @start_time).round(3)
      @stdout << "  (#{duration}s)\n"

      @stdout << @errors.join
    end

    def result
      { stdout: @stdout, error_count: @errors.count}
    end
  end
end