class ApplicationEventLogger < EventLogger::Base

  @queue = :application_event_logger
  @event_name = "Application"

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

  def params
    event_session[:params]
  end
end
