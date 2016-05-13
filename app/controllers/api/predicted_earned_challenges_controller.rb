class API::PredictedEarnedChallengesController < ApplicationController
  include PredictorData

  before_filter :ensure_student?, only: [:update]

  # GET api/predicted_earned_challenges
  def index
    if current_user.is_student?(current_course)
      @student = current_student
      @update_challenges = true
    else
      @student = NullStudent.new
      @update_challenges = false
    end
    @challenges = predictor_challenges(@student)
  end

  # POST api/predicted_earned_challenges/:id
  def update
    prediction = PredictedEarnedChallenge.where(
      student: current_student,
      id: params[:id]
    ).first

    prediction.points_earned = params[:points_earned]
    prediction.save

    # This should be extracted with the rest of the event_loggers
    PredictorEventJob.new(
      data: predictor_event_attrs(prediction.challenge, prediction.valid?)
    ).enqueue

    if prediction.valid?
      render json: {
        id: prediction.id,
        points_earned: prediction.points_earned
      }
    else
      render json: {
        errors:  prediction.errors.full_messages
        },
        status: 400
    end
  end

  private

  # This should be extracted with the rest of the event_loggers
  def predictor_event_attrs(challenge, prediction_saved)
    {
      prediction_type: "challenge",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      challenge_id: params[:challenge_id],
      predicted_points: params[:predicted_score],
      possible_points: challenge.point_total,
      created_at: Time.now,
      prediction_saved_successfully: prediction_saved
    }
  end
end
