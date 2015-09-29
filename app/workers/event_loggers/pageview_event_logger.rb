class PageviewEventLogger < EventLogger
  @queue= :pageview_event_logger
  @retry_limit = 3
  @retry_delay = 60
end
