require 'active_record_spec_helper'
require 'resque_spec/scheduler'

require_relative '../toolkits/event_loggers/shared_examples'
require_relative '../toolkits/event_loggers/attributes'
require_relative '../toolkits/event_loggers/event_session'

# PredictorEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe PredictorEventLogger, type: :background_job do
  include InQueueHelper # get help from ResqueSpec
  include Toolkits::EventLoggers::SharedExamples
  include Toolkits::EventLoggers::Attributes
  extend Toolkits::EventLoggers::EventSession

  # pulls in #event_session attributes from EventLoggers::EventSession
  # creates course, user, student objects, and a request double
  define_event_session_with_request

  include InQueueHelper # get help from ResqueSpec

  let(:new_logger) { PredictorEventLogger.new(event_session) }
  let(:logger_attrs) { predictor_logger_attrs } # pulled in from Toolkits::EventLoggers::Attributes

  # shared examples for EventLogger subclasses
  it_behaves_like "an EventLogger subclass", PredictorEventLogger, "predictor"
  it_behaves_like "EventLogger::Enqueue is included", PredictorEventLogger, "predictor"
end
