class LoginEventLogger < EventLogger

  # queue name
  @queue= :login_event_logger
  @success_message = "Login event was successfully created in mongo"
  @failure_message = "Login event failed creation in mongo"

  # message that posts to the log when being queued
  @start_message = "Starting LoginEventLogger"

  # perform block that is ultimately called by Resque
  def self.perform(event_type, data={})
    super # be like EventLogger
  end

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, self.class, 'login', @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_at(scheduled_time, self.class, 'login', @attrs)
  end

  def enqueue
    Resque.enqueue(self.class, 'login', @attrs)
  end
end
