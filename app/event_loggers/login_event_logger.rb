class LoginEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  @queue= :login_event_logger
  @event_type = "login"

  @success_message = "Login event was successfully created in mongo"
  @failure_message = "Login event failed creation in mongo"

  # message that posts to the log when being queued
  @start_message = "Starting LoginEventLogger"

  # perform block that is ultimately called by Resque
  def self.perform(event_type, data={})
  end
end
