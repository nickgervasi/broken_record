module BrokenRecord::Aggregators
  describe BugsnagAggregator do
    let(:bugsnag_aggregator) { BugsnagAggregator.new }
    let(:logger) { StringIO.new }

    let(:aggregator) { bugsnag_aggregator }

    describe '#report_results' do
      include_context 'aggregator setup'
      let(:klass) { String }
      subject { bugsnag_aggregator.report_results(klass) }
      it 'notifies Bugsnag with the correct data' do
        expected_exception = kind_of(BrokenRecord::InvalidRecordException)
        expected_context = {
          context: 'file1:55',
          grouping_hash: "String-[\"file0:55\"]",
          ids: '3',
          error_count: 1,
          message: 'invalid String model 3',
          class: String
        }

        expect(bugsnag_aggregator).to receive(:notify).ordered.with(expected_exception, expected_context)

        expected_exception = kind_of(BrokenRecord::InvalidRecordException)
        expected_context = {
          context: 'file1:55',
          grouping_hash: "String-[\"file1:55\", \"line2:105\"]",
          ids: '4',
          error_count: 1,
          message: 'invalid String model 4',
          class: String
        }

        expect(bugsnag_aggregator).to receive(:notify).ordered.with(expected_exception, expected_context)

        expected_exception = kind_of(BrokenRecord::InvalidRecordException)
        expected_context = {
          context: 'file1:55',
          grouping_hash: "String-[\"file1:55\", \"line2:105\"]",
          ids: '5',
          error_count: 1,
          message: 'invalid String model 5',
          class: String
        }

        expect(bugsnag_aggregator).to receive(:notify).ordered.with(expected_exception, expected_context)


        subject
      end
    end
  end
end
