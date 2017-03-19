require 'spec_helper'

module BrokenRecord
  describe JobResult do
    let(:start_time) { Time.new 2015/01/01 }
    let(:end_time) { Time.new 2015/01/02 }
    let(:job) { Job.new(klass:Object) }
    let(:job_result) { JobResult.new(job) }

    before(:each) do
      allow(Time).to receive(:now).and_return(start_time, end_time)
    end

    it 'records the start time and stop time correctly' do
      job_result.start_timer
      job_result.stop_timer
      expect(job_result.start_time).to eq(start_time)
      expect(job_result.end_time).to eq(end_time)
    end

    it 'adds errors correctly' do
      job_result.add_error(id: 1, error_type: 'Invalid Record', message: 'Missing Title')
      job_result.add_error(id: 2, error_type: 'Invalid Record', message: 'Missing Name')
      job_result.add_error(error_type: 'Loading Error', message: 'Whaaaaat!')
      expect(job_result.normalized_errors).to eq([
                                                  {id:1, message:'Missing Title', error_type:'Invalid Record'},
                                                  {id:2, message:'Missing Name', error_type:'Invalid Record'},
                                                  {id:nil, message:'Whaaaaat!', error_type:'Loading Error'}
                                                 ])
      expect(job_result.errors).to eq(["\e[1;31mMissing Title\e[0m\n", "\e[1;31mMissing Name\e[0m\n", "\e[1;31mWhaaaaat!\e[0m\n"])
    end
  end
end
