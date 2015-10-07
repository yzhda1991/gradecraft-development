class GradeUpdatePerformer < ResqueJob::Performer
  def setup
    @grade_id = @attrs[:grade_id]
    @grade = fetch_grade_with_assignment
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @save_scores_outcome = require_success { @grade.save_student_and_team_scores }

    if @grade.assignment.notify_released?
      @notify_grade_outcome = require_success { notify_grade_released } 
    end
  end

  def outcome_messages
    puts "Student and team scores #{scores_message} for grade ##{@grade_id}"
    puts notify_grade_message if @notify_grade_outcome
  end

  protected

  def scores_message
    @save_scores_outcome.success? ? "saved succcessfully" : "failed to save"
  end

  def notify_grade_message
    if @notify_grade_outcome.success?
      puts "Successfully sent notification of grade release."
    else
      puts "Failed to send grade release notification."
    end
  end

  def fetch_grade_with_assignment
    Grade.where(id: @grade_id).includes(:assignment).load.first
  end

  def notify_grade_released
    NotificationMailer.grade_released(@grade.id).deliver
  end
end

class GradeUpdaterJob < ResqueJob::Base
  @queue = :grade_updater
  @performer_class = GradeUpdatePerformer
end
