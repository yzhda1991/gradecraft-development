class Challenges::ChallengeGradesController < ApplicationController
  before_action :ensure_staff?

  before_action :find_challenge
  before_action :use_current_course

  # GET /challenges/:challenge_id/challenge_grade?team_id=:team_id
  def new
    @team = current_course.teams.find(params[:team_id])
    @challenge_grade = ChallengeGrade.new
  end

  # POST /challenge_grades
  def create
    @challenge_grade = current_course.challenge_grades.new(challenge_grade_params)
    @team = @challenge_grade.team
    if @challenge_grade.save

      if ChallengeGradeProctor.new(@challenge_grade).viewable?
        ChallengeGradeUpdaterJob.new(challenge_grade_id: @challenge_grade.id).enqueue
      end

      redirect_to challenge_path(@challenge),
        notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully graded"
    else
      render action: "new"
    end
  end

  # Grade many teams on a particular challenge at once
  # GET /challenges/:challenge_id/challenge_grades/mass_edit
  def mass_edit
    @teams = current_course.teams.alpha
    @challenge_grades = @teams.map { |t| @challenge.challenge_grades.find_or_initialize_for_team(t) }
  end

  # PUT /challenges/:challenge_id/challenge_grades/mass_update
  def mass_update
    filter_params_with_no_challenge_grades!
    if @challenge.update_attributes(challenge_params)

      challenge_grade_ids = []
      @challenge.challenge_grades.each do |challenge_grade|
        if challenge_grade.previous_changes[:raw_points].present?
          challenge_grade_ids << challenge_grade.id
        end
      end

      challenge_grade_ids.each { |id| ChallengeGradeUpdaterJob.new(challenge_grade_id: id).enqueue }

      redirect_to challenge_path(@challenge),
        notice: "#{@challenge.name} #{term_for :challenge} successfully graded"
    else
      render action: "mass_edit"
    end
  end

  # PUT /challenges/:challenge_id/challenge_grades/release
  def release
    @challenge_grades =
      @challenge.challenge_grades.find(params[:challenge_grade_ids])
    @challenge_grades.each do |challenge_grade|
      challenge_grade.update(status: "Released")
    end
    flash[:notice] = "Updated #{(term_for :challenge).titleize} Grades!"
    redirect_to challenge_path(@challenge)
  end

  private

  def challenge_params
    params.require(:challenge).permit challenge_grades_attributes: [:raw_points, :status, :team_id, :id]
  end

  def challenge_grade_params
    params.require(:challenge_grade).permit :name, :raw_points, :status, :challenge_id, :feedback,
      :team_id, :final_points, :adjustment_points, :adjustment_points_feedback
  end

  def find_challenge
    @challenge = current_course.challenges.find(params[:challenge_id])
  end

  # This is used to check whether or not the challenge grades being created have any associated data
  # No data? Don't create empty grades for teams
  def filter_params_with_no_challenge_grades!
    params[:challenge][:challenge_grades_attributes] = params[:challenge][:challenge_grades_attributes].delete_if do |key, value|
      value[:raw_points].blank?
    end
  end
end
