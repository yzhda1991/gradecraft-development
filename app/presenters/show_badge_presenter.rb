require "./lib/showtime"

class ShowBadgePresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def badge
    properties[:badge]
  end

  def student
    properties[:student]
  end

  def title
    badge.name
  end

  def teams
    properties[:teams]
  end

  def params
    properties[:params]
  end

  def team
    teams.find_by(id: params[:team_id]) if params[:team_id].present?
  end

  def students
    if team
      course.students_being_graded_by_team(team)
    else
      course.students_being_graded
    end
  end

  def earned_badges
    if student
      student.student_visible_earned_badges_for_badge(badge)
    else
      badge.earned_badges
    end
  end
end
