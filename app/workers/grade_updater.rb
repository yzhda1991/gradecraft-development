class GradeUpdater
  @queue= :gradeupdater

  def self.perform(grade_id)
  end
end

# NOTE: this is not the same as the GradebookUpdaterJob
class GradeUpdaterJob < ResqueJob::Base
  # defaults
  @queue = :grade_updater # put all jobs in the 'main' queue
  @performer_class = GradeUpdatePerformer
  @success_message = "Grade update notification mailer was successfully delivered."
  @failure_message = "Grade update notification mailer was not delivered."
end

class GradeUpdatePerformer < ResqueJob::Performer
  def setup
    @grade_id = @attrs[:grade_id]
    @grade = fetch_grade_with_assignment
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @outcome.require_success { @grade.save_student_and_team_scores }

    if @grade.assignment.notify_released?
      @outcome.require_success { notify_grade_released }
    end
  end

  protected

  def fetch_grade_with_assignment
    Grade.where(id: @grade_id).includes(:assignment).load.first
  end

  def notify_grade_released
    NotificationMailer.grade_released(@grade.id).deliver
  end
end
