require "porch"
require_relative "login_event/find_course_membership"
require_relative "login_event/log_job_starting"
require_relative "login_event/log_job_ended"
require_relative "login_event/prepare_login_event_data"
require_relative "login_event/update_last_login"
require_relative "login_event/record_login_event"

module EventLoggers
  class LoginEvent
    include Porch::Organizer

    rescue_from StandardError do |exception|
      Rails.logger.error exception.message
    end

    def log(data)
      with(data.merge(created_at: Time.now)) do |chain|
        chain.add PrepareLoginEventData
        chain.add LogJobStarting
        chain.add FindCourseMembership
        chain.add UpdateLastLogin
        chain.add RecordLoginEvent
        chain.add LogJobEnded
      end
      log_failures
    end

    def log_later(data)
      EventLoggerJob.set(queue: :login_event_logger)
        .perform_later self.class.name, "log", data
    end

    private

    def log_failures
      Rails.logger.error(context.message) if context.failure?
    end
  end
end
