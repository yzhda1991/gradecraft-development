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
    @event_attrs ||= params ? base_attrs.merge(param_attrs) : base_attrs
  end

  def param_attrs
    { assignment_id: assignment_id, score: score, possible: possible }
  end

  # params method is defined in ApplicationEventLogger
  def assignment_id
    if params[:assignment]
      params[:assignment].to_i
    end
  end

  def score
    if params[:score]
      params[:score].to_i
    end
  end

  def possible
    if params[:possible]
      params[:possible].to_i
    end
  end
end
