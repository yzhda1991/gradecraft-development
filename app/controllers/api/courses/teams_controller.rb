class API::Courses::TeamsController < ApplicationController
  before_action :ensure_staff?

  # GET api/courses/:course_id/teams
  def index
    course = Course.includes(:teams).find params[:course_id]
    teams = course.teams.select(:id, :name).order(:name) if course.has_teams?
    render json: MultiJson.dump(teams: teams, term_for_team: term_for(:team)), status: :ok
  end
end
