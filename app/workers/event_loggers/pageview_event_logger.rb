class PageviewEventLogger < EventLogger
  @queue= :pageview_event_logger
  @start_message = "Starting PageviewEventLogger"
end
