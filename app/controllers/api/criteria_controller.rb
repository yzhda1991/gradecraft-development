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
end
