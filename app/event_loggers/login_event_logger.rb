class LoginEventLogger < EventLogger::Base
  include EventLogger::Enqueue
  enqueue_as :login

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
end
