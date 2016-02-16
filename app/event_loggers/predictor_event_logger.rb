class PredictorEventLogger < EventLogger::Base
  include EventLogger::Enqueue
  enqueue_as :predictor

  @queue= :predictor_event_logger
  @start_message = "Starting PredictorEventLogger"
  @success_message = "Predictor event was successfully created in mongo"
  @failure_message = "Predictor event failed creation in mongo"
end
