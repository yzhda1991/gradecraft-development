class API::PredictedEarnedChallengesController < ApplicationController
  include PredictorData

  before_filter :ensure_student?, only: [:update]

  # GET api/predicted_earned_challenges
  def index
    if current_user_is_student?
      @student = current_student
      @update_challenges = !student_impersonation?
    else
      @student = NullStudent.new
      @update_challenges = false
    end
    @challenges = predictor_challenges(@student)
  end

  # POST api/predicted_earned_challenges/:id
  def update
    @prediction = PredictedEarnedChallenge.where(
      student: current_student,
      id: params[:id]
    ).first

    if @prediction.present?
      @prediction.predicted_points = params[:predicted_points]

      if @prediction.save
        PredictorEventJob.new(data: predictor_event_attrs(@prediction)).enqueue
        render "api/predicted_earned_articles/prediction", status: 200
      else
        render :errors, status: 400
      end
    else
      render json: { errors: [{ detail: "unable to find prediction" }], success: false },
        status: 404
    end
  end

  private

  # This should be extracted with the rest of the event_loggers
  def predictor_event_attrs(prediction)
    {
      prediction_type: "challenge",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      challenge_id: params[:id],
      predicted_points: params[:predicted_points],
      possible_points: prediction.challenge.try(:full_points),
      created_at: Time.now,
      prediction_saved_successfully: prediction.valid?
    }
  end
end
