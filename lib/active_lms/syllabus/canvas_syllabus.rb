require "canvas"

module ActiveLMS
  class CanvasSyllabus
    def initialize(access_token)
      @client = Canvas::API.new(access_token)
    end

    def course(id)
      course = nil
      client.get_data("/courses/#{id}") { |data| course = data }
      course
    end

    def courses
      @courses || begin
        @courses = []
        client.get_data("/courses", enrollment_type: "teacher") do |data|
          @courses += data
        end
      end
      @courses
    end

    def assignments(course_id, assignment_ids=nil)
      assignments = []

      if assignment_ids.nil?
        client.get_data("/courses/#{course_id}/assignments", published: true) do |data|
          assignments += data
        end
      else
        [assignment_ids].flatten.uniq.compact.each do |assignment_id|
          assignments << self.assignment(course_id, assignment_id)
        end
      end

      assignments
    end

    def assignment(course_id, assignment_id)
      assignment = nil
      client.get_data("/courses/#{course_id}/assignments/#{assignment_id}") do |data|
        assignment = data
      end
      assignment
    end

    def grades(assignment_ids)
    end

    private

    attr_reader :client
  end
end
