require 'bugsnag'
require 'bugsnag-capistrano/deploy'

module BrokenRecord
  class InvalidRecordException < StandardError; end

  module Aggregators

    class BugsnagAggregator < ResultAggregator

      MAX_IDS = 500
      BUGSNAG_API_KEY_ERROR = 'Bugsnag API Key must be set!'.freeze

      def report_job_start
        configure_bugsnag!
        notify_deploy
      end

      def report_results(klass)
        super(klass)

        klass_summary = {}

        @aggregated_results[klass].errors.each do |reportable_error|
          klass_summary[reportable_error.message] ||= {
            record_ids: [],
            context: reportable_error.error_context,
            stacktrace: reportable_error.stacktrace
          }

          klass_summary[reportable_error.message][:record_ids] << reportable_error.id
        end

        klass_summary.each do |error_message, error_data|
          ids = error_data[:record_ids]
          exception = InvalidRecordException.new("#{error_message} - #{ids.count} errors")
          exception.class.define_singleton_method(:name) { klass.name }
          exception.set_backtrace(error_data[:stacktrace])

          notify(
            exception,
            context: error_data[:context],
            grouping_hash: "#{klass.name}-#{error_data[:stacktrace]}",
            ids: ids.first(MAX_IDS).join(', '),
            error_count: ids.count,
            message: error_message,
            class: klass
          )
        end
      end

      private

      def notify(exception, options)
        Bugsnag.notify(exception) do |report|
          report.context = options[:context]
          report.grouping_hash = options[:grouping_hash]

          report.add_tab(:custom, options.slice(:ids, :error_count, :message, :class))
        end
      end

      # This does not mean you need Capistrano for deploy, but since Bugsnag 6.0, they removed
      # the native deploy notifications, and instead of using the REST API we are using Bugsnag's
      # recommended solution for notifying from rake tasks by using the `bugsnag-capistrano` gem.
      # Instead of requiring the tasks however, we are requiring the Deploy class which the
      # built-in rake tasks are using.
      #
      # [Rake Upgrade Docs](https://docs.bugsnag.com/api/deploy-tracking/rake/)
      def notify_deploy
        Bugsnag::Capistrano::Deploy.notify(
          repository: ENV['BROKEN_RECORD_REPOSITORY'],
          branch: ENV['BROKEN_RECORD_BRANCH']
        )
      end

      def configure_bugsnag!
        raise BUGSNAG_API_KEY_ERROR unless BrokenRecord::Config.bugsnag_api_key

        Bugsnag.configure do |c|
          c.notify_release_stages = ['production']
          c.release_stage = 'production'
          c.api_key = BrokenRecord::Config.bugsnag_api_key
          c.app_version = Date.today.to_s
          c.app_type = 'validation'
          c.delivery_method = :synchronous
        end
      end
    end
  end
end
