require "./lib/showtime"

class Info::DashboardWeeklyStatsPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def points_this_week
    student.points_earned_for_course_this_week(course)
  end

  def grades_this_week
    student.grades_released_for_course_this_week(course)
  end

  def badges_this_week
    student.earned_badges_for_course_this_week(course)
  end

  def has_points_this_week?
    student.points_earned_for_course_this_week(course).present?
  end

  def has_grades_this_week?
    student.grades_released_for_course_this_week(course).any?
  end

  def has_badges_this_week?
    student.earned_badges_for_course_this_week(course).any?
  end

  def has_weekly_stats?
    has_points_this_week? || has_grades_this_week? || has_badges_this_week?
  end
end