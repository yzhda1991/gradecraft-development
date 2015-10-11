require_relative '../test_helper'
class GradeExportTest
  def subject
    lambda { GradeExportJob.new({ user_id: 18, course_id: 3 }) }.call
  end

  def logger
    Rails.logger
  end

  def run(cycles)
    puts "Starting test for GradeExportJob."

    puts "Running normal enqueues, should happen right now:"
    cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    cycles.times { subject.enqueue_in(10) }
  end
end

GradeExportTest.new.run(3)
