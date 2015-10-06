# NOTE: this is not the same as the GradebookExporterJob
class GradeExporterJob < ResqueJob::Base
  # defaults
  @queue = :gradebook_exporter # put all jobs in the 'main' queue
  @performer_class = GradeExportPerformer
  @success_message = "Grade export notification mailer was successfully delivered."
  @failure_message = "Grade export notification mailer was not delivered."
end

class GradeExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @outcome = Outcome.new do
      if @course.present? and @user.present?
        fetch_csv_data
        notify_grade_export # the result of this block determines the outcome
      end
    end
  end

  protected

  def fetch_user
    User.find @attrs[:user_id]
  end

  def fetch_course
    Course.find @attrs[:course_id]
  end

  def fetch_csv_data
    @csv_data = @course.research_grades_for_course(@course)
  end

  def notify_grade_export
    NotificationMailer.grade_export(@course, @user, @csv_data).deliver
  end
end

