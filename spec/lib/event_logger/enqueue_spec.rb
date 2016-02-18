require 'rails_spec_helper'

include Toolkits::EventLoggers::SharedExamples

RSpec.describe EventLogger::Enqueue, type: :background_job do
  let(:logger_attrs) { Hash.new }
  let(:new_logger) { TestEventLogger.new logger_attrs }

  it_behaves_like "EventLogger::Enqueue is included", TestEventLogger, "test"
end
