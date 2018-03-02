module BrokenRecord::Aggregators
  describe ResultAggregator do
    let(:result_aggregator) { ResultAggregator.new }

    describe '#initialize' do
      it 'initializes with an empty aggregated_results instance variable' do
        expect(result_aggregator.instance_variable_get(:@aggregated_results)).to eq({})
      end
    end

    describe '#add_result' do
      let(:klass) { String }
      subject { result_aggregator.add_result(job_result) }
      let(:job_result) { instance_double(BrokenRecord::JobResult)}
      it 'stores a job result' do
        expect(job_result).to receive_message_chain(:job, :klass => :blah)
        subject
        expected_aggregated_results = { blah: job_result }
        expect(result_aggregator.instance_variable_get(:@aggregated_results)).to eq(expected_aggregated_results)
      end
    end

    describe '#report_results' do
      let(:klass) { String }
      subject { result_aggregator.report_results(klass) }
      it 'delegates to subclass' do
        subject
      end
    end

    describe '#report_job_start' do
      subject { result_aggregator.report_job_start }
      it 'delegates to subclass' do
        subject
      end
    end

    describe '#report_final_results' do
      subject { result_aggregator.report_final_results }
      it 'delegates to subclass' do
        subject
      end
    end

    describe '#count' do
      subject { result_aggregator.count(:blah) }
      let(:job_result) { instance_double(BrokenRecord::JobResult)}

      before do
        allow(job_result).to receive(:errors) { ['error'] }
        expected_aggregated_results = { blah: job_result }
        result_aggregator.instance_variable_set(:@aggregated_results, expected_aggregated_results)
      end

      it { is_expected.to be 1 }
    end

    describe '#success?' do
      subject { result_aggregator.success? }
      context 'no errors' do
        let(:job_result) { instance_double(BrokenRecord::JobResult)}

        before do
          allow(job_result).to receive(:errors) { [] }
          expected_aggregated_results = { blah: job_result }
          result_aggregator.instance_variable_set(:@aggregated_results, expected_aggregated_results)
        end

        it { is_expected.to be true }
      end

      context 'errors' do
        let(:job_result) { instance_double(BrokenRecord::JobResult)}

        before do
          allow(job_result).to receive(:errors) { ['error'] }
          expected_aggregated_results = { blah: job_result }
          result_aggregator.instance_variable_set(:@aggregated_results, expected_aggregated_results)
        end

        it { is_expected.to be false }
      end
    end
  end
end
