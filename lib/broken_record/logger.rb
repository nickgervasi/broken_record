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
      test_results.each { |result| total_errors += result[:errors] }
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

    # Instance Methods

    def initialize
      @errors = 0
      @stdout = ""
    end

    def start_log
      @start_time = Time.now
    end

    def log_error(message)
      @stdout << "[FAIL]\n".red if @errors == 0
      @stdout << "#{message.red}\n"
      @errors += 1
    end

    def log_message(message)
      @stdout << "#{message}"
    end

    def log_result
      @stdout << "[PASS]\n".green if @errors == 0
    end

    def log_duration
      duration = (Time.now - @start_time).round(3)
      @stdout << "\tTime: #{duration}s\n"
    end

    def result
      { stdout: @stdout, errors: @errors}
    end
  end
end