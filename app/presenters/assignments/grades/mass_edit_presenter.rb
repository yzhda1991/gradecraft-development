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
      { group: group, grade: Grade.find_or_create(assignment.id, group.students.first.id) }
    end
  end
end
