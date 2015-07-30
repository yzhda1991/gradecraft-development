class MetricsController < ApplicationController
  before_filter :ensure_staff?

  before_action :find_metric, only: [:update, :destroy]

  respond_to :html, :json

  def new
    @metric = Metric.new params[:metric]
    respond_with @metric, layout: false
  end

  def create
    @metric = Metric.create params[:metric]
    respond_with @metric, layout: false, serializer: ExistingMetricSerializer
  end

  def destroy
    @rubric = @metric.rubric
    @metric.destroy
    respond_with @metric, layout: false
  end

  def update
    @metric.update_attributes params[:metric]
    respond_with @metric, layout: false
  end

  def update_order
    Metric.update params[:metric_order].keys, params[:metric_order].values
    render nothing: true
  end

  private

  def serialized_metric
    ExistingMetricSerializer.new(@metric.includes(:tiers)).to_json
  end

  def find_metric
    @metric = Metric.find params[:id]
  end
end
