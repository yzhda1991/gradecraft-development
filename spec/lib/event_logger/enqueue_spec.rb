require 'rails_spec_helper'

include Toolkits::EventLoggers::SharedExamples

class TestEventLogger
  @queue = :test_event_logger

  include EventLogger::Enqueue

  def event_type
    "test"
  end
end

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe EventLogger::Enqueue, type: :background_job do
  include InQueueHelper # get help from ResqueSpec

  let(:logger_attrs) {{}}
  let(:new_logger) { TestEventLogger.new logger_attrs }

  it_behaves_like "EventLogger::Enqueue is included", TestEventLogger, "test"
end
