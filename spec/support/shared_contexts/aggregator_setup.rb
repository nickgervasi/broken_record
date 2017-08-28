shared_context 'aggregator setup' do
  let(:object_result0) { BrokenRecord::JobResult.new(BrokenRecord::Job.new(klass: Object)) }
  let(:array_result0) { BrokenRecord::JobResult.new(BrokenRecord::Job.new(klass: Array)) }
  let(:string_result0) { BrokenRecord::JobResult.new(BrokenRecord::Job.new(klass: String)) }

  def error_message(id, model_klass)
    "invalid #{model_klass} model #{id}"
  end

  def create_invalid_model_error_stub(id, object_klass)
    message = "#{object_klass} #{id} is invalid"
    stubbed_error = contract_double(BrokenRecord::ReportableError,
                                    id: id,
                                    stacktrace: ['file0:55'],
                                    message: error_message(id, object_klass),
                                    error_context: 'file1:55')
  end

  def create_model_validation_exception_error(id, object_klass)
    stubbed_error = contract_double(BrokenRecord::ReportableError,
                                    id: id,
                                    message: error_message(id, object_klass),
                                    stacktrace: ['file1:55', 'line2:105'],
                                    error_context: 'file1:55')
  end

  def create_validator_exception_error(id, object_klass)
    stubbed_error = contract_double(BrokenRecord::ReportableError,
                                    id: id,
                                    message: error_message(id, object_klass),
                                    stacktrace: ['file1:55', 'line2:105'],
                                    error_context: 'file1:55')
  end

  def toggle_timers(object_result, duration)
    allow(Time).to receive(:now).and_return(Time.new(2017, 1, 1))
    object_result.start_timer
    allow(Time).to receive(:now).and_return(Time.new(2017, 1, 1) + duration)
    object_result.stop_timer
  end

  before(:each) do
    id = 0
    toggle_timers(object_result0, 25)
    stubbed_error = create_invalid_model_error_stub(id += 1, Object)
    object_result0.add_error(stubbed_error)

    toggle_timers(array_result0, 11)
    stubbed_error = create_invalid_model_error_stub(id += 1, Array)
    array_result0.add_error(stubbed_error)

    toggle_timers(string_result0, 0.234)

    stubbed_error = create_invalid_model_error_stub(id += 1, String)
    string_result0.add_error(stubbed_error)
    stubbed_error = create_model_validation_exception_error(id += 1, String)
    string_result0.add_error(stubbed_error)
    stubbed_error = create_validator_exception_error(id += 1, String)
    string_result0.add_error(stubbed_error)
    aggregator.add_result(object_result0)
    aggregator.add_result(array_result0)
    aggregator.add_result(string_result0)
  end
end
