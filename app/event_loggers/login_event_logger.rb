# This class is responsible for handling circumstances in which a user has
# logged into a course and a record needs to be made of that login
# circumstances.
#
# It has a dedicated :login_event_logger queue in order to
# handle throttling through resque-throttle, and sets a custom @analytics_class
# so that the .perform block in the superclass will generate the event using
# Analytics::LoginEvent instead of the default Analytics::Event mongoid class.
#
# The most notable behavior here is that the .perform block is caching the
# data before the superclass generates the Analytics event so that it can
# update the previous_last_login_at on the analytics event record. This may
# be extracted into a separate job in a future iteration of this workflow
#
class LoginEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :login_event_logger
  @event_name = "Login"
  @analytics_class = Analytics::LoginEvent

  # instance methods, for use as a LoginEventLogger instance

  # Used by enqueuing methods in EventLogger::Enqueue
  def event_type
    "login"
  end

  ## class methods, for use when being called directly by Resque

  # perform block that is ultimately called by Resque
  def self.perform(event_type, data = {})
    logger.info "Starting #{@queue} with data #{data}"
    @cached_data = data
    data[:last_login_at] = previous_last_login_at
    super
    update_last_login if course_membership
  end

  def self.previous_last_login_at
    if course_membership && course_membership.last_login_at
      course_membership.last_login_at.to_i
    end
  end

  def self.update_last_login
    course_membership.update_attributes(last_login_at: @cached_data[:created_at])
  end

  def self.course_membership
    @course_membership ||= CourseMembership.where(course_membership_attrs).first
  end

  def self.course_membership_attrs
    { course_id: @cached_data[:course_id], user_id: @cached_data[:user_id] }
  end
end
