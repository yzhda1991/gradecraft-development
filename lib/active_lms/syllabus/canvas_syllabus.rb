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
        client.get_data("/courses/#{course_id}/assignments") do |data|
          data.select { |assignment| assignment["published"] }.each do |assignment|
            assignments << assignment
          end
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

    def grades(course_id, assignment_ids, grade_ids=nil)
      grades = []
      params = { assignment_ids: assignment_ids,
                 student_ids: "all",
                 include: ["assignment", "course", "user"] }
      client.get_data("/courses/#{course_id}/students/submissions", params) do |data|
        if grade_ids.nil?
          grades += data
        else
          filtered_ids = [grade_ids].flatten.uniq.compact.map(&:to_s)
          data.select { |grade| filtered_ids.include?(grade["id"].to_s) }.each do |grade|
            grades << grade
          end
        end
      end
      grades
    end

    def user(id)
      user = nil
      client.get_data("/users/#{id}/profile") { |data| user = data }
      user
    end

    private

    attr_reader :client
  end
end
