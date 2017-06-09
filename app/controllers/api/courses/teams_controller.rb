class API::Courses::TeamsController < ApplicationController
  # GET api/course/:course_id/teams
  def index
    @teams = Course.find(params[:course_id]).teams.select(:id, :name).order(:name)
    render json: MultiJson.dump(@teams)
  end
end
