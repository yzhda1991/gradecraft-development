require_relative '../test_helper'

class GradebookExporterTest
  def subject
    lambda { GradebookExporterJob.new({ user_id: 1, course_id: 3 }) }.call
  end

  def run(cycles)
    puts "Starting test for GradebookExporterJob."

    puts "Running normal enqueues, should happen right now:"
    cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    cycles.times { subject.enqueue_in(10) }
  end
end

GradebookExporterTest.new.run(3)
