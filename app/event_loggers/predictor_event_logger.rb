class PredictorEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :predictor_event_logger
  @event_name = "Predictor"

  # instance methods
  def event_type
    "predictor"
  end

  def event_attrs
    @event_attrs ||= base_attrs.merge({
      assignment_id: assignment_id,
      score: score,
      possible: possible
    })
  end

  # params method is defined in ApplicationEventLogger
  def assignment_id
    params[:assignment].to_i if params[:assignment]
  end

  def score
    params[:score].to_i if params[:score]
  end

  def possible
    params[:possible].to_i if params[:possible]
  end
end
