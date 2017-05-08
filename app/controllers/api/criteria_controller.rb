require_relative "../../services/removes_criterion_expectations"
require_relative "../../services/updates_criterion_expectations"


class API::CriteriaController < ApplicationController

  # GET api/assignments/:assignment_id/criteria
  def index
    assignment = current_course.assignments.find params[:assignment_id]
    rubric = assignment.rubric
    @criteria =
      rubric.criteria.ordered.includes(:levels).order("levels.points").order("levels.sort_order").select(
        :id, :name, :description, :max_points, :order
      )
  end

  # PUT /api/criteria/:criterion_id/levels/:level_id/set_expectations
  def set_expectations
    criterion = Criterion.find(params[:criterion_id])
    level = Level.find(params[:level_id])
    result = Services::UpdatesCriterionExpectations.update criterion, level
    if result
       @criterion = Criterion.includes(:levels).order("levels.points").order("levels.sort_order").select(
        :id, :name, :description, :max_points, :order
      ).find(params[:criterion_id])
      render "api/criteria/show", success: true, status: 200
    else
      render json: {
        message: "failed to update criterion", success: false
        },
        status: 400
    end
  end

  # PUT api/criteria/:id/remove_expectations
  def remove_expectations
    criterion = Criterion.find(params[:criterion_id])
    result = Services::RemovesCriterionExpectations.update criterion
    if result
      @criterion = Criterion.includes(:levels).order("levels.points").order("levels.sort_order").select(
        :id, :name, :description, :max_points, :order
      ).find(params[:criterion_id])
      render "api/criteria/show", success: true, status: 200
    else
      render json: {
        message: "failed to update criterion", success: false
        },
        status: 400
    end
  end
end
