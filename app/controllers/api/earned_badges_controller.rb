require_relative "../../services/creates_earned_badge"

class API::EarnedBadgesController < ApplicationController
  # POST /api/earned_badges
  def create
    result = Services::CreatesEarnedBadge.award params[:earned_badge]
    render json: result.earned_badge
  end

  # DELETE /api/earned_badges/:id
  def destroy
    earned_badge = EarnedBadge.where(id: params[:id]).first
    if earned_badge.present? && earned_badge.destroy
      render json: { message: "Earned badge successfully deleted", success: true },
        status: 200
    else
      render json: { message: "Earned badge failed to delete", success: false },
        status: 400
    end
  end
end