module BrokenRecord
  class ReportableError < Struct.new(:id, :message, :error_context, :stacktrace)
    def self.prettify_stacktrace(stacktrace, e)
      stacktrace.grep(Regexp.new(Rails.root.to_s)).map{|line| line.gsub("#{Rails.root}/", '')}
    end
  end
end
