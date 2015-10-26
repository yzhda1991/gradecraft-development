class PredictorEventJob < ResqueJob::Base
  @queue = :predictor_events
  @performer_class = PredictorEventPerformer
end
