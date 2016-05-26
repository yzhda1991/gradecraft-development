class ChallengeGradesController < ApplicationController

  before_filter :ensure_staff?, except: [:show]
  before_action :find_challenge_grade, only: [:show, :edit, :update, :destroy]
  before_action :find_challenge, only: [:show, :edit, :challenge, :destroy, :update ]

  # GET /challenge_grades/new?challenge_id=:challenge_id?team_id=:team_id
  def new
    @team = current_course.teams.find(params[:team_id])
    @challenge = current_course.challenges.find(params[:challenge_id])
    @challenge_grade = @team.challenge_grades.new
    @title = "Grading #{@team.name}'s #{@challenge.name}"
  end

  # POST /challenge_grades
  def create
    @challenge_grade = current_course.challenge_grades.new(params[:challenge_grade])
    @challenge = @challenge_grade.challenge
    @team = @challenge_grade.team
    if @challenge_grade.save

      ChallengeGradeUpdaterJob.new(challenge_grade_id: @challenge_grade.id).enqueue

      redirect_to @challenge,
        notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully graded"
    else
      render action: "new"
    end
  end

  # GET /challenge_grades/:id
  def show
    @team = @challenge_grade.team
    @title = "#{@team.name}'s #{@challenge_grade.name} Grade"
  end

  # GET /challenge_grades/:id/edit
  def edit
    @title = "Editing #{@challenge.name} Grade"
    @team = @challenge_grade.team
  end

  # POST /challenges_grades/:id
  def update
    @team = @challenge_grade.team
    if @challenge_grade.update_attributes(params[:challenge_grade])

      ChallengeGradeUpdaterJob.new(challenge_grade_id: @challenge_grade.id).enqueue

      redirect_to @challenge,
        notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully updated"
    else
      render action: "edit"
    end
  end

  # DELETE /challenge_grades/:id
  # May be worth it to pull this into a service
  def destroy
    @team = @challenge_grade.team

    @challenge_grade.destroy
    @team.challenge_grade_score
    @team.students.each do |student|
      @team.students.collect do |student|
        ScoreRecalculatorJob.new(user_id: student.id, course_id: current_course.id)
      end.each(&:enqueue)
    end
    @team.average_score

    redirect_to challenge_path(@challenge),
      notice: "#{@team.name}'s grade for #{@challenge.name} has been successfully deleted."
  end

  private

  def find_challenge_grade
    @challenge_grade = current_course.challenge_grades.find(params[:id])
  end

  def find_challenge
    @challenge = @challenge_grade.challenge
  end

end
