# This class is responsible for handling circumstances in which a user has
# logged into a course and a record needs to be made of that login
# circumstances.
#
class LoginEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :login_event_logger

  # Used by enqueuing methods in EventLogger::Enqueue
  def event_type
    "login"
  end

  # perform block that is ultimately called by Resque
  def self.perform(event_type, data = {})
    logger.info "Starting LoginEventLogger with data #{data}"

    # let's use a Performer class to handle the workflow here since it's
    # relatively dense, and we don't want to have to set any class-level
    # instance variables to handle the logic as theoretically that could
    # cause issues in threaded environments
    #
    outcome = LoginEventPerformer.new({ data: data }, logger).perform

    # get the message from the LoginEventPerformer outcome and log it
    logger.info outcome.message if outcome.message
  end
end
