require 'rails_spec_helper'


# TestEventLogger is required from /spec/support/test_classes/event_logger/test_event_logger
RSpec.describe EventLogger::Enqueue, type: :background_job do
  include Toolkits::EventLoggers::SharedExamples
  extend Toolkits::EventLoggers::EventSession

  let(:logger_attrs) { Hash.new }
  let(:new_logger) { TestEventLogger.new event_session }

  define_event_session # from Toolkits::EventLoggers::EventSession

  before { allow(new_logger).to receive(:attrs) { logger_attrs }}

  # taken from Toolkits::EventLoggers::SharedExamples
  it_behaves_like "EventLogger::Enqueue is included", TestEventLogger, "test"
end
