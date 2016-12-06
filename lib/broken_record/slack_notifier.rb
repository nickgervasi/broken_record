require 'net/http'
module BrokenRecord
  class SlackNotifier
    def initialize(options)
      @options = BrokenRecord::Config.slack_options.merge(options)
    end

    def send!(message)
      if defined?(Rails) && Rails.env.development?
        puts message
      else
        slack_params = options.merge(text: message)
        uri = URI('https://slack.com/api/chat.postMessage')
        uri.query = URI.encode_www_form(slack_params)
        Net::HTTP.get(uri)
      end
    end

    private

    def options
      default_options.merge(@options)
    end

    def default_options
      {
        token: slack_token,
        channel: '#eng-viking-master',
        parse: 'none',
        link_names: '1',
        pretty: '1',
        username: 'ValidationMaster',
        icon_emoji: ':llama:',
      }
    end

    def slack_token
      ENV['SLACK_API_TOKEN']
    end
  end
end
