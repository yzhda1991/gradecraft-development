require_relative './event_logger'

class PageviewEventLogger < EventLogger
  @queue= :pageview_event_logger
  @start_message = "Starting PageviewEventLogger"

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, self.class, @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_in(elapsed_time, self.class, @attrs)
  end

  def enqueue
    Resque.enqueue(self.class, @attrs)
  end
end
