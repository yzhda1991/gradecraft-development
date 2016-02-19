class API::CriteriaController < ApplicationController

  # GET api/assignments/:id/criteria
  def index
    assignment = current_course.assignments.find params[:id]
    rubric = assignment.rubric
    @criteria = rubric.criteria.ordered.includes(:levels).order("levels.points").select(
      :id, :name, :description, :max_points, :order
    )
  end
end
