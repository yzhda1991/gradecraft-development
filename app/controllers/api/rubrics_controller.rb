class API::RubricsController < ApplicationController

  # GET api/rubric/:id
  def show
    @rubric = Rubric.find params[:id]
    @criteria =
      @rubric.criteria.ordered.includes(:levels)
    @levels = Level.where(criterion_id: @criteria.pluck(:id)).order("criterion_id").order("points").order("sort_order")
  end
end
