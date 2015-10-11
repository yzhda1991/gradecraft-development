module EnqueueJobTests
  def enqueue_job_tests
    puts "Running normal enqueues, should happen right now:"
    send(:cycles).times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    send(:cycles).times { subject.enqueue_in(10) }
  end
end
