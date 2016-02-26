# This should be inherited by all other EventLogger classes in the application,
# or at least ones being defined in /app/event_loggers.
#
# The most pertinent behaviors here are the definition of an application-
# specific #base_attrs method which will be used as a basis for all other
# event_attrs hashes in EventLogger classes throughout the application
#
# Also event_session[:params] here is being redefined as #params in the
# interest of added clarity for the use of EventLogger params in situations
# where they're passed directly into the event logger class
class ApplicationEventLogger < EventLogger::Base
  @queue = :application_event_logger
  @event_name = "Application"

  attr_reader :event_session

  # Used by enqueuing methods in EventLogger::Enqueue
  def event_type
    "application"
  end

  # this is the default attribute set for EventLogger classes
  # should be extended in #attrs inside of child classes for better
  # granularity when more specific attributes are needed
  def base_attrs
    @base_attrs ||= {
      course_id: event_session[:course].try(:id),
      user_id: event_session[:user].try(:id),
      student_id: event_session[:student].try(:id),
      user_role: event_session[:user].role(event_session[:course]),
      created_at: Time.zone.now
    }
  end

  # event_session is defined in EventLogger::Base
  def params
    event_session[:params]
  end
end
