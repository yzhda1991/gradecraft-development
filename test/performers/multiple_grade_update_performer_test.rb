require_relative '../test_helper'
class MultipleGradeUpdaterTest
  def subject
    lambda { MultipleGradeUpdaterJob.new({ grade_ids: [10, 20, 30] }) }.call
  end

  def run(cycles)
    puts "Starting test for MultipleGradeUpdaterJob."

    puts "Running normal enqueues, should happen right now:"
    cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    cycles.times { subject.enqueue_in(10) }
  end
end

# MultipleGradeUpdaterTest.new.run(3)
