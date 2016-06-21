require "./lib/showtime"

class Students::DashboardPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def score_for_course
    student.cached_score_for_course(course)
  end

  def grade_scheme_elements
    GradeSchemeElement.unscoped.for_course(course).order_by_lowest_points
  end

  def current_element
    student.grade_for_course(course)
  end

  def next_element
    student.get_element_level(course, :next)
  end

  def previous_element
    student.get_element_level(course, :previous)
  end

  def points_to_next_level
    current_element.points_to_next_level(student, course)
  end

  def progress_percent
    current_element.progress_percent(student)
  end
end
