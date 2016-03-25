require "./lib/showtime"

class SyllabusPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def assignments_for(assignment_type)
    assignment_type.assignments.includes(:assignment_type, :unlock_conditions)
  end

  def assignment_visible?(assignment)
    assignment.visible_for_student?(student) || grade_visible?(assignment)
  end

  def name_visible?(assignment)
    assignment.name_visible_for_student?(student) || grade_visible?(assignment)
  end

  def points_visible?(assignment)
    assignment.points_visible_for_student?(student) ||
      grade_visible?(assignment)
  end

  def grade_for(assignment)
    student.grade_for_assignment(assignment)
  end

  def grade_visible?(assignment)
    if view_context.current_user.is_student?(course)
      student.grade_released_for_assignment?(assignment)
    else
      grade_for(assignment).instructor_modified
    end
  end

  def group_for(assignment)
    student.group_for_assignment(assignment)
  end

  def submission_for(assignment)
    student.submission_for_assignment(assignment)
  end

  def open?(assignment)
    assignment.student_logged? && assignment.open?
  end

  def locked?(assignment)
    assignment.is_unlockable? && !assignment.is_unlocked_for_student?(student)
  end

  def submittable?(assignment)
    assignment.accepts_submissions? &&
        assignment.is_unlocked_for_student?(student)
  end
end