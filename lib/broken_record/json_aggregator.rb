require 'json'

module BrokenRecord
  class JsonAggregator < ResultAggregator
    def report_final_results
      json = @aggregated_results.reduce({}) do |acc, (klass, job_results)|
        acc[klass.name] = {
          duration: duration(klass),
          invalid_records: job_results.map(&:normalized_errors).reject(&:empty?)
        }
        acc
      end

      File.open('broken_records_results.json', 'w') { |f| f.puts(JSON.generate(json)) }
    end
  end
end
