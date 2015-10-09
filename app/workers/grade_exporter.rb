class GradeExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success(messages) do
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
    NotificationMailer.grade_export(@course, @user, @csv_data).deliver_now
  end

  def messages
    {
      success: "Grade export notification mailer was successfully delivered.",
      failure: "Grade export notification mailer was not delivered."
    }
  end

end

# todo: need to add specs for the GradeExportJob subclass
class GradeExportJob < ResqueJob::Base
  @queue = :grade_exporter
  @performer_class = GradeExportPerformer
end
