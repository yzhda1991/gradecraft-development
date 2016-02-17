class PageviewEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :pageview_event_logger

  def event_type
    "pageview"
  end
end
