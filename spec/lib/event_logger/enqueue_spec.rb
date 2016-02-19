require 'rails_spec_helper'


# TestEventLogger is required from /spec/support/test_classes/event_logger/test_event_logger
RSpec.describe EventLogger::Enqueue, type: :background_job do
  include Toolkits::EventLoggers::SharedExamples
  extend Toolkits::EventLoggers::EventSession

  let(:new_logger) { TestEventLogger.new event_session }

  define_event_session # from Toolkits::EventLoggers::EventSession

  # taken from Toolkits::EventLoggers::SharedExamples
  it_behaves_like "EventLogger::Enqueue is included", TestEventLogger, "test"
end
