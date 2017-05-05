class API::LevelBadgesController < ApplicationController
  before_action :ensure_staff?

  # POST /api/level_badges
  def create
    @level_badge = LevelBadge.new level_badge_params
    if @level_badge.save
      render "api/level_badges/show", success: true, status: 201
    else
      render json: {
        message: "failed to save badge on level",
        errors: @level_badge.errors.messages,
        success: false
        }, status: 400
    end
  end

  # DELETE /api/level_badges/:id
  def destroy
    level_badge = LevelBadge.where(id: params[:id]).first
    if level_badge.present? && level_badge.destroy
      render json: { message: "Earned badge successfully deleted", success: true },
        status: 200
    else
      render json: { message: "Earned badge failed to delete", success: false },
        status: 400
    end
  end

  private

  def level_badge_params
    params.require(:level_badge).permit :badge_id, :level_id
  end
end
