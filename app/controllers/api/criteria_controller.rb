require_relative "../../services/removes_criterion_expectations"
require_relative "../../services/updates_criterion_expectations"

class API::CriteriaController < ApplicationController

  def create
    @criterion = Criterion.new(criterion_params)

    if @criterion.save
      @levels = @criterion.levels.order("criterion_id").order("points").order("sort_order")
      render "api/criteria/show", status: 201
    else
      render json: { message: "criterion failed to create", success: false }, status: 400
    end
  end

  # GET api/assignments/:assignment_id/criteria
  def index
    assignment = current_course.assignments.find params[:assignment_id]
    rubric = assignment.rubric
    @criteria =
      rubric.criteria.ordered
    @levels = Level.where(criterion_id: @criteria.pluck(:id)).order("criterion_id").order("points").order("sort_order")
  end

  # PUT api/criteria/:id
  def update
    @criterion = Criterion.find(params[:id])

    if @criterion.update_attributes(criterion_params)
      render "api/criteria/show", status: 200
    else
      render json: {
        errors: [{ detail: "failed to update criterion" }], success: false
        }, status: 500
    end
  end

  # DELETE api/criteria/:id
  def destroy
    criterion = Criterion.find(params[:id])
    if criterion.destroy
      render json: { message: "criterion successfully deleted", success: true },
        status: 200
    else
      render json: { message: "criterion failed to delete", success: false },
        status: 400
    end
  end

  def update_order
    params[:criteria_ids].each_with_index do |id, index|
      Criterion.find(id).update(order: index)
    end
    @criteria = Criterion.where(id: params[:criteria_ids]).ordered
    if @criteria.pluck(:id) == params[:criteria_ids]
      render "api/criteria/index", status: 200
    else
      render "api/criteria/index", status: 400
    end
  end

  # PUT /api/criteria/:criterion_id/levels/:level_id/set_expectations
  def set_expectations
    criterion = Criterion.find(params[:criterion_id])
    level = Level.find(params[:level_id])
    result = Services::UpdatesCriterionExpectations.call criterion, level
    if result
      @criterion = Criterion.includes(:levels).find(params[:criterion_id])
      @levels = @criterion.levels.order("points").order("sort_order")
      render "api/criteria/show", success: true, status: 200
    else
      render json: {
        message: "failed to update criterion", success: false
      }, status: 400
    end
  end

  # PUT api/criteria/:id/remove_expectations
  def remove_expectations
    criterion = Criterion.find(params[:criterion_id])
    result = Services::RemovesCriterionExpectations.call criterion
    if result
      @criterion = Criterion.includes(:levels).find(params[:criterion_id])
      @levels = @criterion.levels.order("points").order("sort_order")
      render "api/criteria/show", success: true, status: 200
    else
      render json: {
        message: "failed to update criterion", success: false
        }, status: 400
    end
  end

  private

  def criterion_params
    params.require(:criterion).permit(:rubric_id, :name, :max_points, :description, :order)
  end
end
