class GradebookExporterJob < ResqueJob::Base
  # defaults
  @queue = :gradebook_exporter # put all jobs in the 'main' queue
  @job_type = "GradebookExporterJob" # for use in logging etc.

  def setup_work
    fetch_user
    fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      fetch_csv_data
      notify_gradebook_export
    end
  end

  def cleanup_work
  end

  def was_sucessful?
  end

  private

  def fetch_user
    @user = User.find @attrs[:user_id]
  end

  def fetch_course
    @course = Course.find @attrs[:course_id]
  end

  def fetch_csv_data
    @csv_data = @course.gradebook_for_course(course)
  end

  def notify_gradebook_export
    NotificationMailer.gradebook_export(course,user,csv_data).deliver
  end
end
