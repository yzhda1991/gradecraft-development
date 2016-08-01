require "./lib/showtime"

class Students::DashboardEarnedPointsAndLevelPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def earned_level
    student.grade_for_course(course).name
  end

  def score
    student.cached_score_for_course(course)
  end

end
