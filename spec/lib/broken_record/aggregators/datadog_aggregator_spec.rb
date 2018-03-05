module BrokenRecord::Aggregators
  describe DatadogAggregator do
    let(:datadog_aggregator) { DatadogAggregator.new }
    let(:client) { double('Dogapi::Client', emit_points: nil) }

    let(:aggregator) { datadog_aggregator }

    describe '#report_results' do
      include_context 'aggregator setup'
      let(:klass) { String }
      subject { datadog_aggregator.report_results(klass) }

      before do
        # Stub datadog client
        datadog_aggregator.instance_variable_set(:@client, client)
        # Stub rails
        rails = double('Rails', root: 'spec')
        allow(rails).to receive(:root).and_return('spec')
        allow(rails).to receive_message_chain(:application, :class, :parent_name) { 'testing' }
        stub_const 'Rails', rails
        # Stub activesupport
        allow_any_instance_of(String).to receive(:underscore) { |string| string }
        # Stub time
        allow(Time).to receive(:now).and_return(Time.new(2017, 1, 1))
      end

      it 'notifies datadog client with the correct data' do
        finished_timer_timestamp = Time.new(2017, 1, 1) + 0.234
        key_string = "validation.errors.count"
        data = [[finished_timer_timestamp, 3]]
        tags = { :tags=>{:stage=>"production", :app=>"testing", :class=>"String"}}
        expect(client).to receive(:emit_points).once.ordered.with(key_string, data, tags)

        key_string = "validation.time"
        data = [[finished_timer_timestamp, 0.234]]
        tags = {:tags=>{:stage=>"production", :app=>"testing", :class=>"String"}}
        expect(client).to receive(:emit_points).once.ordered.with(key_string, data, tags)

        subject
      end
    end
  end
end
