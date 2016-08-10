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
    student.grade_for_course(course).try(:name)
  end

  def earned_level_sentence
    "You have achieved the #{ earned_level } level" || "You have not yet earned a level"
  end

  def score
    student.cached_score_for_course(course)
  end
end
