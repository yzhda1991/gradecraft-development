require "./lib/showtime"

class SubmissionPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def assignment
    course.assignments.find assignment_id
  end

  def assignment_id
    properties[:assignment_id]
  end

  def course
    properties[:course]
  end
end
