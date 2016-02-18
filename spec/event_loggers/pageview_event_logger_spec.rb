require "rails_spec_helper"

include Toolkits::EventLoggers::SharedExamples
include Toolkits::EventLoggers::Attributes

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec

  let(:new_logger) { PageviewEventLogger.new(logger_attrs) }
  let(:logger_attrs) { pageview_logger_attrs } # pulled in from Toolkits::EventLoggers::Attributes

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", PageviewEventLogger, "pageview"
  it_behaves_like "EventLogger::Enqueue is included", PageviewEventLogger, "pageview"
end
