require 'broken_record/slack_notifier'

module BrokenRecord
  class SlackAggregator < ResultAggregator
    def report_final_results
      notifier = SlackNotifier.new({
        icon_emoji: success? ? ':white_check_mark:' : ':x:',
        username: "#{app_name} ValidationMaster"
      })

      if success?
        notifier.send!("\nAll models validated successfully.")
      else
        notifier.send!("\n#{@total_errors} errors were found while running validations.")
      end
    end

  end
end
