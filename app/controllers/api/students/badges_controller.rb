class API::Students::BadgesController < ApplicationController
  include PredictorData

  before_filter :ensure_staff?

  # GET api/students/:student_id/badges
  def index
    @student = User.find(params[:student_id])
    @update_predictions = false
    @badges = predictor_badges(@student)
    render template: "api/badges/index"
  end
end
