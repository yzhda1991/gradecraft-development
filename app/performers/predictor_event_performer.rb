# @mz todo: add specs
class PredictorEventPerformer < ResqueJob::Performer
  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    require_success(messages) do
      Analytics::Event.create predictor_event_attrs
    end
  end

  private

  def predictor_event_attrs
    { event_type: "predictor" }.merge @attrs[:data]
  end
  
  def messages
    {
      success: "Predictor analytics event was successfully created.",
      failure: "Predictor analytics event failed to create."
    }
  end
end
