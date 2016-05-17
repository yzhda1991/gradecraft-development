class Challenges::ChallengeGradesController < ApplicationController
  before_filter :ensure_staff?

  # Grade many teams on a particular challenge at once
  # GET /challenges/:challenge_id/challenge_grades/mass_edit
  def mass_edit
    @challenge = current_course.challenges.find(params[:challenge_id])
    @teams = current_course.teams
    @title = "Quick Grade #{@challenge.name}"
    @challenge_score_levels = @challenge.challenge_score_levels
    @challenge_grades = @teams.map do |t|
      @challenge.challenge_grades.where(team_id: t).first ||
        @challenge.challenge_grades.new(team: t, challenge: @challenge)
    end
  end

  # PUT /challenges/:challenge_id/challenge_grades/mass_update
  def mass_update
    @challenge = current_course.challenges.find(params[:id])
    if @challenge.update_attributes(params[:challenge])

      enqueue_multiple_challenge_grade_update_jobs(mass_update_challenge_grade_ids)

      redirect_to challenge_path(@challenge),
        notice: "#{@challenge.name} #{term_for :challenge} successfully graded"
    else
      render action: "mass_edit"
    end
  end

  # Changing the status of a grade - allows instructors to review "Graded"
  # grades, before they are "Released" to students
  # POST /challenges/:challenge_id/challenge_grades/edit_status
  def edit_status
    @title = "#{@challenge.name} Grade Statuses"
    @challenge_grades =
      @challenge.challenge_grades.find(params[:challenge_grade_ids])
  end

  # PUT /challenges/:challenge_id/challenge_grades/update_status
  def update_status
    @challenge_grades =
      @challenge.challenge_grades.find(params[:challenge_grade_ids])
    @challenge_grades.each do |challenge_grade|
      challenge_grade.update_attributes!(params[:challenge_grade].reject { |k, v| v.blank? })
    end
    flash[:notice] = "Updated #{(term_for :challenge).titleize} Grades!"
    redirect_to challenge_path(@challenge)
  end

  private

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_challenge_grade_update_jobs(challenge_grade_ids)
    challenge_grade_ids.each { |id| ChallengeGradeUpdaterJob.new(challenge_grade_id: id).enqueue }
  end

  # Retrieve all grades for an assignment if it has a score
  def mass_update_challenge_grade_ids
    @challenge.challenge_grades.inject([]) do |memo, challenge_grade|
      scored_changed = challenge_grade.previous_changes[:score].present?
      if scored_changed && challenge_grade.graded_or_released?
        memo << challenge_grade.id
      end
      memo
    end
  end

end
