module BrokenRecord::Aggregators
  describe BugsnagAggregator do
    let(:bugsnag_aggregator) { BugsnagAggregator.new }
    let(:logger) { StringIO.new }

    # Shared context variables
    let(:aggregator) { bugsnag_aggregator }

    describe '#report_job_start' do
      include_context 'aggregator setup'
      subject(:report_job_start) { bugsnag_aggregator.report_job_start }

      context 'when bugsnag_api_key is not set' do
        it 'raises an error' do
          expect { report_job_start }.to raise_error BugsnagAggregator::BUGSNAG_API_KEY_ERROR
        end
      end

      context 'when bugsnag_api_key is set' do
        before { allow(BrokenRecord::Config).to receive(:bugsnag_api_key).and_return('api_key') }

        it 'configures and notifies bugsnag' do

          expect(Bugsnag).to receive(:configure)
          expect(Bugsnag::Capistrano::Deploy).to receive(:notify)
          report_job_start
        end
      end
    end

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
