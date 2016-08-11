require "./lib/showtime"

class Info::DashboardWeeklyStatsPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def badges
    properties[:badges]
  end

  def points_this_week
    if student
      student.points_earned_for_course_this_week(course)
    end
  end

  def grades_this_week
    if student
      student.grades_released_for_course_this_week(course)
    end
  end

  def badges_this_week
    if student
      student.earned_badges_for_course_this_week(course)
    else
      badge.earned_badges_this_week_count
    end
  end

  def has_points_this_week?
    if student
      student.points_earned_for_course_this_week(course).present?
    end
  end

  def has_grades_this_week?
    if student
      student.grades_released_for_course_this_week(course).any?
    end
  end

  def has_badges_this_week?
    if student
      student.earned_badges_for_course_this_week(course).any?
    else
      badge.earned_badges_this_week_count > 0
    end
  end

  def has_weekly_stats?
    has_points_this_week? || has_grades_this_week? || has_badges_this_week?
  end
end