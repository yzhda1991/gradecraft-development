class ScoreRecalculatorJob < ResqueJob::Base
  @queue = :multiple_grade_updater
  @performer_class = ScoreRecalculatorPerformer
end

class ScoreRecalculatorPerformer < ResqueJob::Performer
  def setup
    @student_id = @attrs[:student_id]
    @course_id = @attrs[:course_id]
    @student = fetch_student
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @outcome = require_success { @student.cache_course_score(@course_id) }
  end

  def logger_messages # prints_to_logger
    if @outcome.success?
      puts "All grades saved and notified correctly."
    elsif complete_failure?
      puts "All grades and notifications failed."
    end
  end

  protected

  def fetch_student
    User.find(@student_id)
  end
end
