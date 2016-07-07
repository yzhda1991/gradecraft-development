require "./lib/showtime"

class Students::DashboardCoursePlannerPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def assignments
    properties[:assignments]
  end

  def to_do_assignment?(assignment)
    assignment.include_in_to_do? && assignment.visible_for_student?(student)
  end

  def assignment_available?(assignment)
    assignment.accepts_submissions? && assignment.is_unlocked_for_student?(student)
  end

  def assignment_starred?(assignment)
    assignment.is_predicted_by_student?(student)
  end

  def assignment_individual?(assignment)
    assignment.is_individual?
  end

  def assignment_submitted?
    student.submission_for_assignment(assignment).present?
  end
end
