class PredictorEventLogger < EventLogger
  @queue= :predictor_event_logger
  @start_message = "Starting PredictorEventLogger"
  @success_message = "Predictor event was successfully created in mongo"
  @failure_message = "Predictor event failed creation in mongo"

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, self.class, 'predictor', @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_at(scheduled_time, self.class, 'predictor', @attrs)
  end

  def enqueue
    Resque.enqueue(self.class, 'predictor', @attrs)
  end
end
