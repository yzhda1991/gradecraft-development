require "showtime"

class Assignments::Grades::MassEditPresenter < Showtime::Presenter
  def assignment
    properties[:assignment]
  end

  def grade_select?
    assignment.grade_select?
  end

  def grade_radio?
    assignment.grade_radio?
  end

  def grade_checkboxes?
    assignment.grade_checkboxes?
  end

  def pass_fail?
    assignment.pass_fail?
  end

  def full_points
    assignment.full_points
  end

  def groups
    assignment.groups
  end

  def assignment_score_levels
    assignment.assignment_score_levels.order_by_points
  end

  def grades_by_group
    assignment.groups.map do |group|
      gradebook = Gradebook.new(assignment, group.students.first)
      { group: group, grade: gradebook.grades.first }
    end
  end
end
