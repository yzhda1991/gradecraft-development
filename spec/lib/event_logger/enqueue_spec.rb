require 'active_record_spec_helper'
require 'resque_spec/scheduler'

require_relative '../../support/test_classes/lib/event_logger/test_event_logger'
require_relative '../../toolkits/event_loggers/shared_examples'
require_relative '../../toolkits/event_loggers/event_session'

# TestEventLogger is required from /spec/support/test_classes/event_logger/test_event_logger
RSpec.describe EventLogger::Enqueue, type: :background_job do
  include Toolkits::EventLoggers::SharedExamples
  extend Toolkits::EventLoggers::EventSession

  let(:new_logger) { TestEventLogger.new event_session }

  define_event_session # from Toolkits::EventLoggers::EventSession

  # taken from Toolkits::EventLoggers::SharedExamples
  it_behaves_like "EventLogger::Enqueue is included", TestEventLogger, "test"

  describe "#event_attrs" do
    it "aliases #base_attrs" do
      expect(new_logger.event_attrs).to eq(new_logger.base_attrs)
    end
  end
end
