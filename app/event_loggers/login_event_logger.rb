class LoginEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :login_event_logger
  @event_name = "Login"
  @analytics_class = Analytics::LoginEvent

  # class methods, for use when being called directly by Resque
  # perform block that is ultimately called by Resque
  def self.perform(event_type, data={})
    @data = data
    super
    update_last_login
  end

  def self.update_last_login
    course_membership.update_attributes(last_login_at: @data[:created_at])
  end

  # instance methods, for use as a LoginEventLogger instance
  def event_type
    "login"
  end

  def event_attrs
    @event_attrs ||= base_attrs.merge({ last_login_at: previous_last_login_at })
  end

  def course_membership
    @course_membership ||= CourseMembership.where(course_membership_attrs).first
  end

  def previous_last_login_at
    course_membership.last_login_at.to_i if course_membership.last_login_at
  end

  def course_membership_attrs
    { course_id: attrs[:course_id], user_id: attrs[:user_id] }
  end
end
