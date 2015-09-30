class PredictorEventLogger < EventLogger
  @queue= :predictor_event_logger
  @start_message = "Starting PredictorEventLogger"
end
