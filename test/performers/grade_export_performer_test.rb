require_relative '../test_helper'

class GradeExportTest

  def subject
    lambda { GradeExportJob.new({ user_id: 1, course_id: 3 }) }.call
  end

  def test
    puts start_message

    puts "Running normal enqueues, should happen right now:"
    @cycles.times { subject.enqueue }

    puts "Running delayed enqueue_in calls, should happen in ten seconds:"
    @cycles.times { subject.enqueue_in(10) }
  end
end

GradeExporterTest.new.run(3)
