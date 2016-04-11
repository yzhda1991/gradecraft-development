require "./lib/showtime"

class Submissions::Presenter < Showtime::Presenter
  include Showtime::ViewContext
  attr_writer :assignment

  def assignment
    @assignment ||= course.assignments.find assignment_id
  end

  def assignment_id
    properties[:assignment_id]
  end

  def course
    properties[:course]
  end

  def group
    return nil unless assignment.has_groups?
    @group ||= course.groups.find group_id
  end

  def group_id
    properties[:group_id]
  end
end
