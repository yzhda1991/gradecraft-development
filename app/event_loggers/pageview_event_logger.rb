class PageviewEventLogger < EventLogger::Base
  include EventLogger::Enqueue
  enqueue_as :pageview

  # queue name
  @queue= :pageview_event_logger
  @success_message = "Pageview event was successfully created in mongo"
  @failure_message = "Pageview event failed creation in mongo"

  # message that posts to the log when being queued
  @start_message = "Starting PageviewEventLogger"
end
