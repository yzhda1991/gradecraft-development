class API::PredictedEarnedBadgesController < ApplicationController

  before_action :ensure_student?
  before_action :ensure_not_impersonating?

  # POST api/predicted_earned_badges
  def create
    @prediction = PredictedEarnedBadge.new predicted_earned_badge_params
    if @prediction.save
      PredictorEventJob.new(data: predictor_event_attrs(@prediction)).enqueue
      render "api/predicted_earned_articles/prediction", status: 201
    else
      render "api/predicted_earned_articles/errors", status: 400
    end
  end

  # POST api/predicted_earned_badges/:id
  def update
    @prediction = PredictedEarnedBadge.where(
      student: current_student,
      id: params[:id]
    ).first

    if @prediction.present?
      @prediction.update predicted_earned_badge_params

      if @prediction.save
        PredictorEventJob.new(data: predictor_event_attrs(@prediction)).enqueue
        render "api/predicted_earned_articles/prediction", status: 200
      else
        render "api/predicted_earned_articles/errors", status: 400
      end
    else
      render json: { errors: [{ detail: "unable to find prediction" }], success: false },
        status: 404
    end
  end

  private

  def predicted_earned_badge_params
    params.require(:predicted_earned_badge).permit(
      :badge_id, :predicted_times_earned
    ).merge(student_id: current_user.id)
  end

  # This should be extracted with the rest of the event_loggers
  def predictor_event_attrs(prediction)
    {
      prediction_type: "badge",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      badge_id: prediction.badge.id,
      predicted_earns: params[:predicted_times_earned],
      multiple_earns_possible: prediction.badge.can_earn_multiple_times,
      predicted_points: badge_predicted_points(prediction),
      point_value_per_badge: prediction.badge.full_points,
      created_at: Time.now,
      prediction_saved_successfully: prediction.badge.valid?
    }
  end

  def badge_predicted_points(prediction)
    prediction.badge.full_points * params[:predicted_times_earned] rescue nil
  end
end
