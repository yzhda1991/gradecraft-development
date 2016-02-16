class PredictorEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :predictor_event_logger

  # name of the events as they'll be stored in the events store in Mongo
  @event_type = "predictor"
end
