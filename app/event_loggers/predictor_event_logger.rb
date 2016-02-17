class PredictorEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :predictor_event_logger

  # instance methods
  def event_type
    "predictor"
  end
end
