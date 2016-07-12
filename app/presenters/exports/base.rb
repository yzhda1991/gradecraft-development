require "showtime"

module Presenters
  module Exports
    class Base < Showtime::Presenter

      def submissions_exports
        @submissions_exports ||= current_course
          .submissions_exports
          .order("updated_at DESC")
          .includes(:assignment, :course, :team)
      end

      def course_analytics_exports
        @course_analytics_exports ||= current_course
          .course_analytics_exports
          .order("updated_at DESC")
          .includes(:course)
      end

      def current_course
        properties[:current_course]
      end

      def current_user
        properties[:current_user]
      end

    end
  end
end
