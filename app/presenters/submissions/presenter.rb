require "./lib/showtime"

module Submissions
  class Presenter < Showtime::Presenter
    include Showtime::ViewContext

    def assignment
      return nil unless assignment_id
      @assignment ||= course.assignments.find assignment_id
    end

    def assignment_id
      properties[:assignment_id]
    end

    def course
      properties[:course]
    end

    def group
      return nil unless assignment.has_groups? && group_id
      @group ||= course.groups.find group_id
    end

    def group_id
      properties[:group_id]
    end
  end
end
