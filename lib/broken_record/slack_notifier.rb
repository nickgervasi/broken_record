require 'net/http'
module BrokenRecord
  class SlackNotifier
    def initialize(initial_options)
      @options = default_options
      @options = @options.merge(initial_options)
      @options = @options.merge(BrokenRecord::Config.slack_options)
    end

    def send!(message)
      return unless @options[:summary]
      if defined?(Rails) && Rails.env.development?
        puts message
      else
        slack_params = @options.merge(text: message)
        uri = URI('https://slack.com/api/chat.postMessage')
        uri.query = URI.encode_www_form(slack_params)
        Net::HTTP.get(uri)
      end
    end

    def send_snippet!(snippet_body, snippet_title)
      return unless @options[:snippet]
      if defined?(Rails) && Rails.env.development?
        puts message
      else
        slack_params = @options.merge({
          title: snippet_title,
          initial_comment: ':heavy_exclamation_mark: @benefitsvm: The validation job failed!',
          icon_emoji: ':x:',
          channels: @options[:channel]
        })

        # Upload file to slack via multipart/form-data
        snippet_file = Tempfile.new
        begin
          snippet_file.write(snippet_body)
          snippet_file.rewind
          encoded_params = slack_params.map{ |key, value| "-F \"#{key}=#{value}\"" }.join(' ')
          `curl -F file=@#{snippet_file.path} #{encoded_params} https://slack.com/api/files.upload`
        ensure
          snippet_file.close
          snippet_file.unlink
        end
      end
    end

    private

    def default_options
      {
        token: slack_token,
        channel: '#eng-viking-master',
        parse: 'none',
        link_names: '1',
        pretty: '1',
        username: 'ValidationMaster',
        icon_emoji: ':llama:',
        summary: true,
        snippet: false
      }
    end

    def slack_token
      ENV['SLACK_API_TOKEN']
    end
  end
end
