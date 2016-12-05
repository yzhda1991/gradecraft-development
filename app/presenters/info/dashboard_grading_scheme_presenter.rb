require "./lib/showtime"

class Info::DashboardGradingSchemePresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def current_element_sentence
    "You have achieved the #{ current_element.name } level" || "You have not yet earned a level"
  end

  def score_for_course
    student.score_for_course(course)
  end

  def course_elements
    GradeSchemeElement.for_course(course).order_by_lowest_points
  end

  # showing first element of grading scheme if current score does not reflect a level
  def first_element
    GradeSchemeElement.for_course(course).order_by_lowest_points.first
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
