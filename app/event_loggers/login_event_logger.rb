class LoginEventLogger < ApplicationEventLogger # pull in EventLogger::Enqueue from ApplicationEventLogger
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :login_event_logger
  @event_name = "Login"
  @analytics_class = Analytics::LoginEvent

  # instance methods, for use as a LoginEventLogger instance
  def event_type
    "login"
  end

  # class methods, for use when being called directly by Resque
  # perform block that is ultimately called by Resque
  def self.perform(event_type, data={})
    @data = data
    data.merge!(last_login_at: previous_last_login_at)
    super
    update_last_login
  end

  def self.previous_last_login_at
    course_membership.last_login_at.to_i if course_membership.last_login_at
  end

  def self.update_last_login
    course_membership.update_attributes(last_login_at: @data[:created_at])
  end

  def self.course_membership
    @course_membership ||= CourseMembership.where(course_membership_attrs).first
  end

  def self.course_membership_attrs
    { course_id: @data[:course_id], user_id: @data[:user_id] }
  end
end
