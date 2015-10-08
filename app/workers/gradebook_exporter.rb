class GradebookExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success do
        fetch_csv_data
        notify_gradebook_export # the result of this block determines the outcome
      end
    end
  end

  def outcome_messages # prints_to_logger
    if outcome_success?
      puts "Gradebook export notification mailer was successfully delivered."
    elsif outcome_failure?
      puts "Gradebook export notification mailer was not delivered."
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
    NotificationMailer.gradebook_export(@course, @user, @csv_data).deliver
  end
end

class GradebookExporterJob < ResqueJob::Base
  @queue = :gradebook_exporter 
  @performer_class = GradebookExportPerformer
end
