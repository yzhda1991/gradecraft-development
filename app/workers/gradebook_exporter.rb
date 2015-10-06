class GradebookExporterJob < ResqueJob::Base
  # defaults
  @queue = :gradebook_exporter # put all jobs in the 'main' queue
  @job_type = "GradebookExporterJob" # for use in logging etc.
  @performer_class = GradebookExportPerformer
  @success_message = "Gradebook export notification mailer was successfully delivered."
  @failure_message = "Gradebook export notification mailer was not delivered."
end

class GradebookExportPerformer < ResqueJob::Performer
  def setup_work
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      fetch_csv_data
      @mailer_outcome = notify_gradebook_export
    end
  end

  def was_successful?
    @mailer_outcome
  end

  private

  def fetch_user
    User.find @attrs[:user_id]
  end

  def fetch_course
    Course.find @attrs[:course_id]
  end

  def fetch_csv_data
    @csv_data = @course.gradebook_for_course(course)
  end

  def notify_gradebook_export
    NotificationMailer.gradebook_export(course,user,csv_data).deliver
  end
end
