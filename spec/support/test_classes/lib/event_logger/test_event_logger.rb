class TestEventLogger
  include EventLogger::Enqueue

  @queue = :test_event_logger

  def event_type
    "test"
  end

  def event_attrs
    { waffles: "true" }
  end

  def self.perform(event_type, data={})
  end
end
