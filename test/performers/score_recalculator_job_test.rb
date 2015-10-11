require_relative '../test_helper'
class ScoreRecalculatorTest
  def subject
    lambda { ScoreRecalculatorJob.new({ user_id: 18, course_id: 3 }) }.call
  end

  def run(cycles)
    puts "Starting test for #{self.class}."

    puts "Running normal enqueues, should happen right now:"
    cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    cycles.times { subject.enqueue_in(10) }
  end
end

ScoreRecalculatorTest.new.run(3)
