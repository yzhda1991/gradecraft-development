# this class can still use EventLogger::Base because it's not calling #event_attrs
# from an instance of this class in order to build the Resque call.
# Instead it's being passed into Resque in the traditional format as a class,
# and doesn't need to internally build #event_attrs for the call
#
# This should be refactored at a later time when the implementation of the
# PredictorEventLogger in the AnalyticsEventsController is updated to use the
# conventional format of:
# PredictorEventLogger.new(event_session).enqueue_in_with_fallback(time_until_enqueue)

class PredictorEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :predictor_event_logger
  @event_name = "Predictor"

  # instance methods
  def event_type
    "predictor"
  end
end
