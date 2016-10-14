class API::ChallengesController < ApplicationController
  before_filter :ensure_student?, only: [:update]


  # GET api/challenges
  def index
    @challenges = current_course.challenges

    if include_student_data?
      @team = current_student.team_for_course(current_course)
      @student = current_student
      @update_predictions = !student_impersonation?

      if !student_impersonation?
        @challenges.includes(:predicted_earned_challenges)
        @predicted_earned_challenges =
          PredictedEarnedChallenge.for_course(current_course).for_student(current_student)
        @grades =
          ChallengeGrade.for_team(@team)
      end
    end
  end

  private

  def include_student_data?
    current_user_is_student? &&
    current_course.challenges.present? &&
    current_student.team_for_course(current_course).present? &&
    current_course.add_team_score_to_student
  end
end





