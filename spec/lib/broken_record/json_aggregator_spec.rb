require 'spec_helper'

module BrokenRecord
  describe JsonAggregator do
    let(:json_aggregator) { JsonAggregator.new }
    let(:job) { Job.new(klass:Object) }
    let(:object_result0) { JobResult.new(Job.new(klass:Object)) }
    let(:object_result1) { JobResult.new(Job.new(klass:Object)) }
    let(:object_result1) { JobResult.new(Job.new(klass:Object)) }
    let(:object_result1) { JobResult.new(Job.new(klass:Object)) }
    let(:string_result0) { JobResult.new(Job.new(klass:String)) }
    let(:string_result1) { JobResult.new(Job.new(klass:String)) }
    let(:json_file) { 'broken_records_results.json' }
    describe '#report_final_results' do
      before(:each) do
        object_result0.start_timer
        object_result0.stop_timer
        object_result0.add_error(1, 'Invalid Record', 'Missing Title')

        object_result1.start_timer
        object_result1.stop_timer
        object_result1.add_error(0, 'Exception', 'Something is wrong')

        string_result0.start_timer
        string_result0.stop_timer
        string_result0.add_error(0, 'Invalid Record', 'F word detected')

        string_result1.start_timer
        string_result1.stop_timer

        json_aggregator.add_result(object_result0)
        json_aggregator.add_result(object_result1)
        json_aggregator.add_result(string_result0)
        json_aggregator.add_result(string_result1)
      end

      it 'creates a json file with formatted errors' do
        expect(File).to_not exist(json_file)

        json_aggregator.report_final_results
        errors = {
          'Object'=> {
            'duration'=>0.0,
            'invalid_records'=>[
              [{'id'=>1, 'message'=>'Missing Title', 'error_type'=>'Invalid Record'}],
              [{'id'=>0, 'message'=>'Something is wrong', 'error_type'=>'Exception'}]
            ]
          },
          'String'=> {
            'duration'=>0.0,
            'invalid_records'=>[
              [{'id'=>0, 'message'=>'F word detected', 'error_type'=>'Invalid Record'}]
            ]
          }
        }
        expect(File).to exist(json_file)
        File.open('broken_records_results.json').each do |line|
          expect(JSON.parse(line)).to eql(errors)
        end
        File.delete(json_file)
      end
    end
  end
end
