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
  class << self
    # perform block that is ultimately called by Resque
    def perform(event_type, data = {})
      logger.info "Starting #{@queue} with data #{data}"
      @cached_data = data
      data[:last_login_at] = previous_last_login_at
      super
      update_last_login if course_membership_present?
    end

    def previous_last_login_at
      # Let's be sure to check here whether last_login_at exists before
      # converting it into an integer. nil.to_i won't produce an error, but it
      # will give us a 0 value where we might instead just mean nil. This could
      # result in a substantial amount of erroneous data on the backend that
      # will be harder to interpret later in analytics.
      #
      if course_membership_present? && course_membership.last_login_at
        course_membership.last_login_at.to_i
      end
    end

    def update_last_login
      course_membership
        .update_attributes(last_login_at: @cached_data[:created_at])
    end

    def course_membership
      @course_membership ||= CourseMembership
        .where(course_membership_attrs)
        .first
    end

    # let's make sure that we've got the necessary attributes present in order
    # to find the CourseMembership before we attempt to find it. There's no good
    # reason to perform a search for the CourseMembership if we know that it
    # can't possibly exist.
    #
    def course_membership_present?
      course_membership_attrs_present? && course_membership
    end

    def course_membership_attrs_present?
      @cached_data[:course_id].present? && @cached_data[:user_id].present?
    end

    def course_membership_attrs
      { course_id: @cached_data[:course_id], user_id: @cached_data[:user_id] }
    end
  end
end
