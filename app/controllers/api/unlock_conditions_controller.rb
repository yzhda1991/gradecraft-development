class API::UnlockConditionsController < ApplicationController
  before_action :ensure_staff?

  # GET /api/assignments/:assignment_id/unlock_conditions
  # GET /api/badges/:badge_id/unlock_conditions
  # GET  /api/grade_scheme_elements/:grade_scheme_element_id/unlock_conditions
  def index
    if params[:assignment_id].present?
      id = params[:assignment_id]
      type = "Assignment"
    elsif params[:badge_id].present?
      id = params[:badge_id]
      type = "Badge"
    elsif params[:grade_scheme_element_id].present?
      id = params[:grade_scheme_element_id]
      type = "GradeSchemeElement"
    end
      @unlock_conditions = UnlockCondition.where(unlockable_id: id, unlockable_type: type)
  end
end
