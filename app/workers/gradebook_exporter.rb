class GradebookExporterJob < ResqueJob::Base
  # defaults
  @queue = :gradebook_exporter # put all jobs in the 'main' queue
  @performer_class = GradebookExportPerformer
  @success_message = "Gradebook export notification mailer was successfully delivered."
  @failure_message = "Gradebook export notification mailer was not delivered."
end

class GradebookExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @outcome = Outcome.new do
      if @course.present? and @user.present?
        fetch_csv_data
        notify_gradebook_export # the result of this block determines the outcome
      end
    end
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
