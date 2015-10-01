require_relative './event_logger'

class PageviewEventLogger < EventLogger
  @queue= :pageview_event_logger
  @start_message = "Starting PageviewEventLogger"

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(elapsed_time)
    if @current_user and @request.format.html?
      Resque.enqueue_in(elapsed_time, self.class, @attrs)
    end
  end
end
