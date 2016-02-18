class TestEventLogger
  @queue = :test_event_logger

  include EventLogger::Enqueue

  def event_type
    "test"
  end
end
