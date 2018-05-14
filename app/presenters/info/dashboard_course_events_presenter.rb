require "./lib/showtime"

class Info::DashboardCourseEventsPresenter < Showtime::Presenter
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

  # collect the assignments that are on the same date as the event
  def assignments_due_on(event)
    assignments.where('DATE(due_at) = ?', event.due_at.to_date)
  end

  def show_add_assignments_to_google_button?(user)
    course.institution.try(:has_google_access?) && course.assignments.any? { |a| AssignmentProctor.new(a).viewable?(user) }
  end
end
