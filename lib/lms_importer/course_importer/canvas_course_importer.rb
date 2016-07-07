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

    def assignment(course_id, assignment_id)
      assignment = nil
      client.get_data("/courses/#{course_id}/assignments/#{assignment_id}") do |a|
        assignment = a
      end
      assignment
    end

    def import_assignments(course_id, assignment_ids, course)
      [assignment_ids].flatten.uniq.compact.each do |assignment_id|
        assignment = self.assignment(course_id, assignment_id)
      end
    end

    private

    attr_reader :client
  end
end
