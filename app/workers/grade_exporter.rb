class GradeExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success do
        fetch_csv_data
        notify_grade_export # the result of this block determines the outcome
      end
    end
  end

  def outcome_messages # prints_to_logger
    if outcome_success?
      puts "Grade export notification mailer was successfully delivered."
    elsif outcome_failure?
      puts "Grade export notification mailer was not delivered."
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

class GradeExportJob < ResqueJob::Base
  @queue = :grade_exporter
  @performer_class = GradeExportPerformer
end
