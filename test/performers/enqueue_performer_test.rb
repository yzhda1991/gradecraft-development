class EnqueuePerformerTest < ConsoleTest::SimpleConsoleTest
  def tests
    puts start_message

    puts "Running normal enqueues, should happen right now:"
    @cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    @cycles.times { subject.enqueue_in(10) }
  end
end
