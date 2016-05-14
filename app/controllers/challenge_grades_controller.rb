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
        if current_course.add_team_score_to_student? &&
          @challenge_grade.is_student_visible?
          @score_recalculator_jobs = @team.students.collect do |student|
            ScoreRecalculatorJob.new(user_id: student.id,
              course_id: current_course.id)
          end
          @score_recalculator_jobs.each(&:enqueue)
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

        if current_course.add_team_score_to_student?
          if student_grades_require_update?
            @score_recalculator_jobs = @team.students.collect do |student|
              ScoreRecalculatorJob.new(user_id: student.id,
                course_id: current_course.id)
            end
            @score_recalculator_jobs.each(&:enqueue)
          end
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

  # DELETE /challenges/:challenge_id/challenge_grades/:id
  def destroy
    @team = @challenge_grade.team

    @challenge_grade.destroy
    @challenge_grade.recalculate_student_and_team_scores

    redirect_to challenge_path(@challenge),
      notice: "#{@team.name}'s grade for #{@challenge.name} has been successfully deleted."
  end

  private

  def student_grades_require_update?
    score_update_required? || visibility_update_required?
  end

  def score_update_required?
    score_changed? && @challenge_grade.is_student_visible?
  end

  def visibility_update_required?
    visibility_changed? && @challenge_grade.is_student_visible?
  end

  def visibility_changed?
    @challenge_grade.previous_changes[:status].present?
  end

  def score_changed?
    @challenge_grade.previous_changes[:score].present?
  end

  def find_challenge_grade
    @challenge_grade = current_course.challenge_grades.find(params[:id])
  end

  def find_challenge
    @challenge = @challenge_grade.challenge
  end

end
