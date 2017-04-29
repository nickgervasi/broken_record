require 'broken_record/slack_notifier'
require 'colorize'

module BrokenRecord
  class SlackAggregator < ResultAggregator
    def report_final_results
      notifier = SlackNotifier.new({
        icon_emoji: success? ? ':white_check_mark:' : ':x:',
        username: "#{app_name} ValidationMaster"
      })

      send_summary(notifier)
      send_snippet(notifier)
    end

    private

    def send_summary(notifier)
      if success?
        notifier.send!("\nAll models validated successfully.")
      else
        notifier.send!("\n#{@total_errors} errors were found while running validations.")
      end
    end

    def send_snippet(notifier)
      # Our snippet should naively show the output from the ConsoleAggregator
      console_aggregator = BrokenRecord::ConsoleAggregator.new
      all_results.each{ |result| console_aggregator.add_result(result) }
      # Store the output of the console aggregator into a StringIO object
      $stdout = StringIO.new
      snippet = all_classes.each { |klass| console_aggregator.report_results(klass) }
      snippet = $stdout.string
      $stdout = STDOUT

      if !success?
        notifier.send_snippet!(snippet.uncolorize, 'Model Validation Failures')
      end
    end
  end
end
