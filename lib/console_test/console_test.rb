module ConsoleTest
  def self.run(&builder_block)
    builder = Builder.new(builder_block)
    builder
  end

  class Builder
  end
end

# desired DSL for later console tests
# ConsoleTest.run( cycles: 3 ) do |runner|
#   runner.subject { GradebookExporterJob.new({ user_id: 1, course_id: 3 }) }
#   runner.message { "Starting #{cycles} GradebookExporterJob test cycles..." }
# 
#   runner.test do |test|
#     test.message { "Running normal enqueues, should happen right now:" }
#     test.action { enqueue }
#   end
# 
#   runner.test do |test|
#     test.message { "Running delayed enqueue_in calls, should happen in ten seconds:" }
#     test.action { enqueue_in(10) }
#   end
# end
# 
# # create the test runner
# @test_runner = ConsoleTest::TestRunner.new
# @test_runner.start_message { "Starting #{cycles} GradebookExporterJob test cycles..." }
# 
# # set a subject for the test
# @test_runner.subject do
#   GradebookExporterJob.new({ user_id: 1, course_id: 3 })
# end
# 
# # add a test for enqueue
# enqueue_test = @test_runner.add_test { enqueue }
# enqueue_test.start_message = "Running normal enqueues, should happen right now:"
# 
# # add a test for enqueue_in
# enqueue_in_test = @test_runner.add_test { enqueue_in(10) }
# enqueue_in_test.start_message = "Running delayed enqueue_in calls, should happen in ten seconds:"
# 
# # run the test
# @test_runner.start
