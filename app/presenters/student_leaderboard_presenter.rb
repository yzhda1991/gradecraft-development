require "./lib/showtime"

class StudentLeaderboardPresenter < Showtime::Presenter
  def course
    properties[:course]
  end

  def display_pseudonyms?
    course.in_team_leaderboard? || course.character_names?
  end

  def has_badges?
    course.has_badges?
  end

  def has_teams?
    course.has_teams?
  end

  def team_id
    properties[:team_id]
  end

  def team
    @team ||= teams.find_by(id: team_id) if team_id
  end

  def teams
    course.teams
  end

  def title
    "Leaderboard"
  end
end
