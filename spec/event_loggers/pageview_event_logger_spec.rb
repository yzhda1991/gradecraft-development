require "rails_spec_helper"


# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec
  include Toolkits::EventLoggers::SharedExamples
  include Toolkits::EventLoggers::Attributes
  extend Toolkits::EventLoggers::EventSession

  define_event_session # pulls in #event_session attributes from EventLoggers::EventSession

  let(:new_logger) { PageviewEventLogger.new(event_session) }
  let(:logger_attrs) { pageview_logger_attrs } # pulled in from Toolkits::EventLoggers::Attributes

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", PageviewEventLogger, "pageview"
  it_behaves_like "EventLogger::Enqueue is included", PageviewEventLogger, "pageview"
end
