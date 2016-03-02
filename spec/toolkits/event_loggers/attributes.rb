module Toolkits
  module EventLoggers
    module Attributes
      def base_logger_attrs
        {
          course_id: 50,
          user_id: 60,
          student_id: 70,
          user_role: "great role",
          page: "/a/great/path",
          created_at: Time.parse("Jan 20 1972")
        }
      end

      # course.id and user.id are built locally in the spec because they
      # must correspond to the course membership being fetched
      def login_logger_attrs
        {
          course_id: course.id,
          user_id: user.id,
          student_id: 90,
          user_role: "great role",
          page: "/a/great/path",
          last_login_at: Time.parse("Jan 20 1962"),
          created_at: Time.parse("Jan 20 1972")
        }
      end

      alias pageview_logger_attrs base_logger_attrs
      alias predictor_logger_attrs base_logger_attrs
    end
  end
end
