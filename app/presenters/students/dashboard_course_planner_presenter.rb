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

  def to_do_assignments
    assignments.select{ |assignment| assignment.include_in_to_do == true && assignment.visible_for_student?(student)== true && assignment.soon? == true }
  end

  def to_do?(assignment)
    assignment.soon? && assignment.include_in_to_do? && assignment.visible_for_student?(student)
  end

  def submittable?(assignment)
    assignment.accepts_submissions? && assignment.is_unlocked_for_student?(student)
  end

  def starred?(assignment)
    assignment.is_predicted_by_student?(student)
  end

  def my_planner?(assignment)
    to_do?(assignment) && starred?(assignment)
  end

  def my_planner_assignments
    assignments.select{ |assignment| my_planner?(assignment) }
  end

  def submitted?(assignment)
    student.submission_for_assignment(assignment).present?
  end

  def empty_message(list_class)
    assignment_term = course.assignment_term.downcase.pluralize
    if list_class == "course-planner"
      "You don't have any #{assignment_term} due in the next week!"
    elsif list_class == "my-planner"
      "You have not predicted any #{assignment_term}! Check out the grade predictor to add #{assignment_term} to this planner."
    end
  end
end
