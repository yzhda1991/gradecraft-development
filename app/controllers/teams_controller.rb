class TeamsController < ApplicationController
  respond_to :html, :json

  before_action :ensure_not_observer?
  before_action :ensure_staff?, except: [:index]
  before_action :use_current_course, only: [:index, :show, :new, :edit]

  def index
    @teams = @course.teams.includes(:leaders).order_by_rank
    if current_user_is_student?
      @team = current_student.team_for_course(@course)
    end
    @team_names_and_scores = @teams.map { |t| { data: t.score, name: t.name } }
  end

  def show
    @team = @course.teams.find(params[:id])
    @students = @team.students.order_by_name
    @challenges = @course.challenges.chronological.alphabetical
  end

  def new
    @team =  @course.teams.new
    @submit_message = "Create #{term_for :team}"
  end

  def create
    @team =  current_course.teams.new(team_params)
    @team.save
    respond_with @team, notice: "Team #{@team.name} successfully created"
  end

  def edit
    @team =  @course.teams.find(params[:id])
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
    params.require(:team).permit :name, :course, :course_id, :average_score,
      :banner, :remove_banner, :rank, :challenge_grade_score,
      team_memberships_attributes: [:id, :student_id, :team_id, :_destroy],
      team_leaderships_attributes: [:id, :leader_id, :team_id, :_destroy],
      leader_ids: [], student_ids: []
  end
end
