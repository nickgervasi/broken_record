module BrokenRecord
  describe JobResult do
    let(:time) { Time.new 2015/01/01 }
    let(:job) { Job.new(klass:Object) }
    let(:job_result) { JobResult.new(job) }

    describe '#start_timer' do
      before { allow(Time).to receive(:now).and_return(time) }
      subject { job_result.start_timer }
      it { is_expected.to eq time }
    end

    describe '#stop_timer' do
      before { allow(Time).to receive(:now).and_return(time) }
      subject { job_result.stop_timer }
      it { is_expected.to eq time }
    end

    describe '#add_error' do
      let(:error) { Struct.new(:id) }
      subject { job_result.add_error(error) }

      it 'modifies errors correctly' do
        subject
        expect(job_result.instance_variable_get(:@errors)).to eq [error]
      end
    end
  end
end
