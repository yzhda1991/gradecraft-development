class CriteriaController < ApplicationController
  before_filter :ensure_staff?

  before_action :find_criterion, only: [:update, :destroy]

  respond_to :json

  def create
    @criterion = Criterion.create params[:criterion]
    respond_with @criterion, layout: false, serializer: ExistingCriterionSerializer
  end

  def destroy
    @rubric = @criterion.rubric
    @criterion.destroy
    render :nothing => true
  end

  def update
    @criterion.update_attributes params[:criterion]
    respond_with @criterion, layout: false
  end

  def update_order
    Criterion.update params[:criterion_order].keys, params[:criterion_order].values
    render nothing: true
  end

  private

  def serialized_criterion
    ExistingCriterionSerializer.new(@criterion.includes(:levels)).to_json
  end

  def find_criterion
    @criterion = Criterion.find params[:id]
  end
end
