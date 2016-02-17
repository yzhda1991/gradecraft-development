require "rails_spec_helper"

include Toolkits::EventLoggers::SharedExamples

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PageviewEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec

  let(:new_logger) { PageviewEventLogger.new(logger_attrs) }
  let(:logger_attrs) {{
    course_id: rand(100),
    user_id: rand(100),
    student_id: rand(100),
    user_role: "great role",
    page: "/a/great/path",
    created_at: Time.parse("Jan 20 1972")
  }}

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", PageviewEventLogger, "pageview"
  it_behaves_like "EventLogger::Enqueue is included", PageviewEventLogger, "pageview"
end
