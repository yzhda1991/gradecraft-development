class LoginEventLogger < EventLogger::Base
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :login_event_logger
  @event_name = "Login"

  def event_type
    "login"
  end

  # perform block that is ultimately called by Resque
  def self.perform(event_type, data={})
    data.merge! last_login_at: course_membership.lost_login_at.to_i
    @data = data
    super
    update_last_login
  end

  def self.update_last_login
    course_membership.update_attribute(:last_login_at, Time.now)
  end

  def self.course_membership
    @course_membership ||= CourseMembership.where(course_membership_attrs).first
  end

  def self.course_membership_attrs
    {
      course_id: @data[:course_id],
      user_id: @data[:user_id]
    }
  end
end
