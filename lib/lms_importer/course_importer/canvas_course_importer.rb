require "canvas"

module LMSImporter
  class CanvasCourseImporter
    def initialize(access_token)
      @client = Canvas::API.new(access_token)
    end

    def course(id)
      @course || begin
        client.get_data("/courses/#{id}") { |course| @course = course }
      end
      @course
    end

    def courses
      @courses || begin
        @courses = []
        client.get_data("/courses", enrollment_type: "teacher") do |courses|
          @courses += courses
        end
      end
      @courses
    end

    def assignments(course_id)
      @assignments || begin
        @assignments = []
        client.get_data("/courses/#{course_id}/assignments") do |assignments|
          @assignments += assignments
        end
      end
      @assignments
    end

    private

    attr_reader :client
  end
end
