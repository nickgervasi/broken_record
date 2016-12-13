module BrokenRecord
  class DatadogAggregator < ResultAggregator

    def initialize
      super
      @timestamp = Time.now
    end

    def report_results(klass)
      super(klass)

      tags = default_tags.merge(class: klass.name.underscore)
      client.emit_points('validation.errors.count', [[@timestamp, all_errors(klass).count]], tags: tags)
      client.emit_points('validation.time', [[@timestamp, duration(klass)]], tags: tags)
    end

    private

    def client
      @client ||= begin
        require 'dogapi'
        Dogapi::Client.new(
          BrokenRecord::Config.datadog_api_key
        )
      end
    end

    def default_tags
      {
        stage: ENV['VALIDATION_ENV'] || 'production',
        app: app_name
      }
    end

  end
end
