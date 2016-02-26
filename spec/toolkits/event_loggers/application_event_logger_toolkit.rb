module Toolkits
  module EventLoggers
    module ApplicationEventLoggerToolkit
      def application_logger_base_attrs
        {
          course_id: event_session[:course].id,
          user_id: event_session[:user].id,
          student_id: event_session[:student].id,
          user_role: "great-role",
          created_at: time_zone_now
        }
      end
    end
  end
end
