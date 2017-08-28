module BrokenRecord::Aggregators
  describe ConsoleAggregator do
    let(:console_aggregator) { ConsoleAggregator.new }
    let(:logger) { StringIO.new }

    let(:aggregator) { console_aggregator }

    describe '#report_results' do
      include_context 'aggregator setup'
      let(:klass) { String }
      subject { console_aggregator.report_results(klass, logger: logger) }

      context 'number of invalid results exceeds the configured default_result_count' do
        before do
          allow(BrokenRecord::Config).to receive(:default_result_count).and_return(5)
        end
        it 'outputs the correct validation data to the logger' do
          subject
          expected = <<-eos
Running validations for String...                                     \e[0;31;49m[FAIL]\e[0m  (0.234s)
3 errors were found while running validations for String
Invalid ids: [3, 4, 5]
Validation errors on first 3 invalid models
\e[0;31;49m    Invalid record in String id=3.
        invalid String model 3\e[0m
\e[0;31;49m    Invalid record in String id=4.
        invalid String model 4\e[0m
\e[0;31;49m    Invalid record in String id=5.
        invalid String model 5\e[0m
eos
          expect(logger.string).to eq expected
        end
      end

      context 'number of invalid results is less than the configured default_result_count' do
        before do
          allow(BrokenRecord::Config).to receive(:default_result_count).and_return(2)
        end
        it 'outputs the correct validation data to the logger' do
          subject
          expected = <<-eos
Running validations for String...                                     \e[0;31;49m[FAIL]\e[0m  (0.234s)
3 errors were found while running validations for String
Invalid ids: [3, 4, 5]
Validation errors on first 2 invalid models
\e[0;31;49m    Invalid record in String id=3.
        invalid String model 3\e[0m
\e[0;31;49m    Invalid record in String id=4.
        invalid String model 4\e[0m
eos

          expect(logger.string).to eq expected
        end
      end
    end

    describe '#report_final_results' do
      subject { console_aggregator.report_final_results(logger: logger) }

      context 'no errors' do
        it 'outputs the correct validation data to the logger' do
          subject
          expected = "\e[0;32;49m\nAll models validated successfully.\e[0m\n"
          expect(logger.string).to eq expected
        end
      end

      context 'errors' do
        include_context 'aggregator setup'
        it 'outputs the correct validation data to the logger' do
          subject
          expected = "\e[0;31;49m\n5 errors were found while running validations.\e[0m\n"
          expect(logger.string).to eq expected
        end
      end
    end
  end
end
