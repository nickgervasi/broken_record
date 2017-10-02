module BrokenRecord::Aggregators
  describe SlackAggregator do
    let(:slack_aggregator) { SlackAggregator.new }
    let(:slack_notifier) { instance_double(BrokenRecord::Services::SlackNotifier, send!: nil, send_snippet!: nil) }
    let(:aggregator) { slack_aggregator }

    describe '#report_final_results' do
      subject { slack_aggregator.report_final_results(notifier: slack_notifier) }

      context 'no errors' do
        it 'outputs the correct validation data to the summary' do
          expect(slack_notifier).to receive(:send!).with("\nAll models validated successfully.")
          expect(slack_notifier).to_not receive(:send_snippet!)
          subject
        end
      end

      context 'errors' do
        include_context 'aggregator setup'
        it 'outputs the correct validation data to the snippet' do
          expect_any_instance_of(BrokenRecord::Aggregators::ConsoleAggregator)
            .to receive(:report_results).with(String, logger: an_instance_of(StringIO))
          expect_any_instance_of(BrokenRecord::Aggregators::ConsoleAggregator)
            .to receive(:report_results).with(Object, logger: an_instance_of(StringIO))
          expect_any_instance_of(BrokenRecord::Aggregators::ConsoleAggregator)
            .to receive(:report_results).with(Array, logger: an_instance_of(StringIO))

          expect_any_instance_of(StringIO).to receive_message_chain(:string, :uncolorize).and_return('stubbed failures')
          expect(slack_notifier).to receive(:send!).with("\n5 errors were found while running validations.")
          expect(slack_notifier).to receive(:send_snippet!).with('stubbed failures', 'Model Validation Failures')
          subject
        end
      end
    end
  end
end
