require_relative './event_logger'

class PageviewEventLogger < EventLogger
  # queue name
  @queue= :pageview_event_logger
  @retry_limit = 3
  @retry_delay = 5

  # message that posts to the log when being queued
  @start_message = "Starting PageviewEventLogger"

  def self.notify_event_outcome(event)
    if event.valid?
      puts "Pageview event was successfully created in mongo."
    else
      puts "Pageview event failed creation in mongo."
    end
  end

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, self.class, 'pageview', @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_in(elapsed_time, self.class, 'pageview', @attrs)
  end

  def enqueue
    Resque.enqueue(self.class, 'pageview', @attrs)
  end
end
