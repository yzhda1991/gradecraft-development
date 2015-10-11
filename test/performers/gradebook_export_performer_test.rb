require_relative '../test_helper'

# create the test runner
@test_runner = ConsoleTest::TestRunner.new
@test_runner.start_message { "Starting #{cycles} GradebookExporterJob test cycles..." }

# set a subject for the test
@test_runner.subject do
  GradebookExporterJob.new({ user_id: 1, course_id: 3 })
end

# add a test for enqueue
enqueue_test = @test_runner.add_test { enqueue }
enqueue_test.start_message = "Running normal enqueues, should happen right now:"

# add a test for enqueue_in
enqueue_in_test = @test_runner.add_test { enqueue_in(10) }
enqueue_in_test.start_message = "Running delayed enqueue_in calls, should happen in ten seconds:"

# run the test
@test_runner.start
