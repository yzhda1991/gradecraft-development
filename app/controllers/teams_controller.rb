class TeamsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_staff?

  def index
    @teams = current_course.teams.order_by_rank.includes(:earned_badges)
    @title = "#{term_for :teams}"
  end

  def show
    @team = current_course.teams.find(params[:id])
    @students = @team.students
    @challenges = current_course.challenges.chronological.alphabetical
    @title = @team.name
  end

  def new
    @team =  current_course.teams.new
    @team_memberships = @team.team_memberships.new
    @title = "Create a New #{term_for :team}"
    @course = current_course
    @users = current_course.users
    @team.team_memberships.build
    @students = current_course.students
    @submit_message = "Create #{term_for :team}"
    respond_with @team
  end

  def create
    @team =  current_course.teams.new(team_params)
    @team.save
    @team.team_memberships.build
    respond_with @team, notice: "Team #{@team.name} successfully created"
  end

  def edit
    @team =  current_course.teams.find(params[:id])
    @title = "Editing #{@team.name}"
    @users = current_course.users
    @students = current_course.students
    @submit_message = "Update #{term_for :team}"
  end

  def update
    @team = current_course.teams.find(params[:id])
    @team.update_attributes(team_params)
    respond_with @team, notice: "Team #{@team.name} successfully updated"
  end

  def destroy
    @team = current_course.teams.find(params[:id])
    @name = "#{@team.name}"
    @team.destroy
    respond_to do |format|
      format.html do
        redirect_to teams_url,
        notice: "#{(term_for :team).titleize} #{@name} successfully deleted"
      end
    end
  end

  private

  def team_params    
    params.require(:team).permit :name, :course, :course_id, :student_ids, :average_score,
      :banner, :rank, :leader_ids, :challenge_grade_score,
      team_memberships_attributes: [:student_id, :team_id],
      team_leaderships_attributes: [:leader_id, :team_id]
  end
end
