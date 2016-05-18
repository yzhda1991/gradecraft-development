class ChallengeGradesController < ApplicationController

  before_filter :ensure_staff?, except: [:show]
  before_action :find_challenge_grade, only: [:show, :edit, :update, :destroy]
  before_action :find_challenge, only: [:index, :show, :edit, :challenge, :destroy ]

  # GET /challenge_grades/:id
  def show
    @team = @challenge_grade.team
    @title = "#{@team.name}'s #{@challenge_grade.name} Grade"
  end

  # GET /challenge_grades/new?challenge_id=:challenge_id&team_id=:team_id
  def new
    @team = current_course.teams.find(params[:team_id])
    @challenge = current_course.challenges.find(params[:challenge_id])
    @challenge_grade = @team.challenge_grades.new
    @title = "Grading #{@team.name}'s #{@challenge.name}"
  end

  # GET /challenge_grades/:id/edit
  def edit
    @title = "Editing #{@challenge.name} Grade"
    @team = @challenge_grade.team
  end

  # POST /challenge_grades
  def create
    @challenge_grade = current_course.challenge_grades.new(params[:challenge_grade])
    @challenge = @challenge_grade.challenge
    @team = @challenge_grade.team
    respond_to do |format|
      if @challenge_grade.save

        if ChallengeGradeProctor.new(@challenge_grade).viewable?
          challenge_grade_updater_job =
            ChallengeGradeUpdaterJob.new(challenge_grade_id: @challenge_grade.id)
          challenge_grade_updater_job.enqueue
        end

        format.html {
          redirect_to @challenge,
          notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully graded"
        }
      else
        format.html { render action: "new" }
      end
    end
  end

  # POST /challenges_grades/:id
  def update
    @team = @challenge_grade.team
    @challenge = @challenge_grade.challenge
    respond_to do |format|
      if @challenge_grade.update_attributes(params[:challenge_grade])

        if ChallengeGradeProctor.new(@challenge_grade).viewable?
          challenge_grade_updater_job =
            ChallengeGradeUpdaterJob.new(challenge_grade_id: @challenge_grade.id)
          challenge_grade_updater_job.enqueue
        end

        format.html {
          redirect_to @challenge,
          notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully updated"
        }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /challenge_grades/:id
  def destroy
    @team = @challenge_grade.team

    @challenge_grade.destroy
    @team.set_challenge_grade_score
    @team.students.each do |student|
      score_recalculator_jobs = @team.students.collect do |student|
        ScoreRecalculatorJob.new(user_id: student.id,
          course_id: current_course.id)
      end
    end
    score_recalculator_jobs.each(&:enqueue)
    @team.set_average_score

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
