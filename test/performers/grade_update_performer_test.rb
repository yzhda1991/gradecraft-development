require_relative "../test_helper"
class GradeUpdaterTest
  def subject
    lambda { GradeUpdaterJob.new({ grade_id: 10 }) }.call
  end

  def run(cycles)
    puts "Starting test for GradeUpdaterJob."

    puts "Running normal enqueues, should happen right now:"
    cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    cycles.times { subject.enqueue_in(10) }
  end
end

# GradeUpdaterTest.new.run(3)
