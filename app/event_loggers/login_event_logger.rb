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

  # Used by enqueuing methods in EventLogger::Enqueue
  def event_type
    "login"
  end

  ## class methods, for use when being called directly by Resque
  class << self
    # perform block that is ultimately called by Resque
    def perform(event_type, data = {})
      logger.info "Starting LoginEventLogger with data #{data}"

      course_membership = find_course_membership(data)
      if course_membership
        data[:last_login_at] = course_membership.last_login_at.try(:to_i)
        course_membership.update_attributes last_login_at: data[:created_at]
      end

      event = Analytics::LoginEvent.create data

      logger.info event_outcome_message(event, data)
    end

    def find_course_membership(data)
      CourseMembership.find_by user_id: data[:user_id],
        course_id: data[:course_id]
    end
  end
end
