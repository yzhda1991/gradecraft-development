class API::Grades::EarnedBadgesController < ApplicationController
  # POST /api/grades/:grade_id/earned_badges
  def create
    render json: EarnedBadge.create(params[:earned_badges])
  end

  # DELETE /api/grades/:grade_id/earned_badges/delete_all
  def delete_all
    if !EarnedBadge.where(grade_id: params[:grade_id]).destroy_all.empty?
      render json: {
        message: "Earned badges successfully deleted", success: true
        }, status: 200
    else
      render json: {
        message: "Earned badges failed to delete", success: false
        }, status: 400
    end
  end
end
