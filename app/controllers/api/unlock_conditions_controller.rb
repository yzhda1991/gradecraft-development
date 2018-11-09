class API::UnlockConditionsController < ApplicationController
  before_action :ensure_staff?, except: :for_course
  before_action :ensure_admin?, only: :for_course
  before_action :use_current_course, except: :for_course

  # GET /api/courses/:id/unlock_conditions
  def for_course
    @unlock_conditions = Course
                          .includes(:unlock_conditions)
                          .find(params[:id])
                          .unlock_conditions
  end

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

  # POST /api/unlock_conditions
  def create
    @unlock_condition = UnlockCondition.new(unlock_condition_params)
    @unlock_condition.course = @course
    if @unlock_condition.save
      render "api/unlock_conditions/show", status: 201
    else
      render json: {
        message: "failed to create condition",
        errors: @unlock_condition.errors.messages,
        success: false
        }, status: 400
    end
  end

  # PUT /api/unlock_conditions/:id
  def update
    @unlock_condition = UnlockCondition.find(params[:id])

    if @unlock_condition.update_attributes(unlock_condition_params)
      render "api/unlock_conditions/show", status: 200
    else
      render json: {
        message: "failed to update condition",
        errors: @unlock_condition.errors.messages,
        success: false
        }, status: 400
    end
  end

  # DELETE /api/unlock_conditions/:id
  def destroy
    @unlock_condition = UnlockCondition.find(params[:id])
    if @unlock_condition.destroy
      render json: { message: "unlock condition successfully deleted", success: true },
        status: 200
    else
      render json: { message: "unlock condition failed to delete", success: false },
        status: 400
    end
  end

  private

  def unlock_condition_params
    params.require(:unlock_condition).permit :unlockable_id, :unlockable_type, :condition_id,
      :condition_type, :condition_state, :condition_value, :condition_date
  end
end
