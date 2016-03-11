class PredictorEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue
  extend EventLogger::Params

  # queue to use for login event jobs
  @queue = :predictor_event_logger

  def event_type
    "predictor"
  end

  def event_attrs
    params ? application_attrs.merge(param_attrs) : application_attrs
  end

  def param_attrs
    { assignment_id: assignment_id, score: score, possible: possible }
  end

  def assignment_id
    return unless params["assignment"]
    params["assignment"].to_i
  end

  def score
    return unless params["score"]
    params["score"].to_i
  end

  def possible
    return unless params["possible"]
    params["possible"].to_i
  end
end
