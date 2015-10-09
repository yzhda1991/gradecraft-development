class GradeUpdatePerformer < ResqueJob::Performer
  def setup
    @grade = fetch_grade_with_assignment
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    require_success(save_scores_messages) do
      @grade.save_student_and_team_scores
    end

    if @grade.assignment.notify_released?
      require_success(notify_released_messages) { notify_grade_released } 
    end
  end

  protected

  def scores_message
    @save_scores_outcome.success? ? "saved succcessfully" : "failed to save"
  end

  def save_scores_messages
    {
      "Student and team scores saved successfully for grade ##{@grade.id}"
      "Student and team scores failed to save for grade ##{@grade.id}"
    }
  end

  def notify_released_messages
    {
      success: "Successfully sent notification of grade release.",
      failure: "Failed to send grade release notification."
    }
  end

  def fetch_grade_with_assignment
    Grade.where(id: @grade.id).includes(:assignment).load.first
  end

  def notify_grade_released
    NotificationMailer.grade_released(@grade.id).deliver
  end
end

class GradeUpdaterJob < ResqueJob::Base
  @queue = :grade_updater
  @performer_class = GradeUpdatePerformer
end
