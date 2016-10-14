class API::PredictedEarnedGradesController < ApplicationController
  include PredictorData

  before_filter :ensure_student?
  before_filter :ensure_not_impersonating?

  # POST api/predicted_earned_grades
  def create
    @prediction = PredictedEarnedGrade.new predicted_earned_grade_params
    if @prediction.save
      PredictorEventJob.new(data: predictor_event_attrs(@prediction)).enqueue
      render "api/predicted_earned_articles/prediction", status: 201
    else
      render "api/predicted_earned_articles/errors", status: 400
    end
  end

  # PUT api/predicted_earned_grades/:id
  def update
    @prediction = PredictedEarnedGrade.where(
      student: current_student,
      id: params[:id]
    ).first

    if @prediction.present?
      @prediction.predicted_points = params[:predicted_points]

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

  def predicted_earned_grade_params
    params.require(:predicted_earned_grade).permit(
      :assignment_id, :predicted_points
    ).merge(student_id: current_user.id)
  end

  # This should be extracted with the rest of the event_loggers
  def predictor_event_attrs(prediction)
    {
      prediction_type: "grade",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      assignment_id: params[:id],
      predicted_points: params[:predicted_points],
      possible_points: prediction.assignment.try(:full_points),
      created_at: Time.now,
      prediction_saved_successfully: prediction.valid?
    }
  end
end
