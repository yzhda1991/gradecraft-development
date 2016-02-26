class PredictorEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue
  extend EventLogger::Params

  # queue to use for login event jobs
  @queue = :predictor_event_logger
  @event_name = "Predictor"

  # this defines filtering methods for all of the keys that will be taken out
  # of the params hash. If the value is a symbol, then a method will be defined
  # using the same name as the params key. If a hash is given, it will define a
  # method using the name of the hash value, and expects the same key name that
  # was used in the params hash
  numerical_params :score, :possible, assignment: :assignment_id

  ## instance methods, for use as a LoginEventLogger instance

  def event_type
    "predictor"
  end

  # params method is defined in ApplicationEventLogger
  def event_attrs
    @event_attrs ||= params ? base_attrs.merge(param_attrs) : base_attrs
  end

  def param_attrs
    { assignment_id: assignment_id, score: score, possible: possible }
  end
end
