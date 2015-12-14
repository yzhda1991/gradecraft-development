class GradeExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success(fetch_csv_messages, max_result_size: 250) do
        fetch_csv_data(@course)
      end

      require_success(notification_messages, max_result_size: 200) do
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
    @csv_data = GradesForResearchExporter.new.research_grades @course
  end

  def notify_grade_export
    NotificationMailer.grade_export(@course, @user, @csv_data).deliver_now
  end

  def fetch_csv_messages
    {
      success: "Successfully fetched CSV grade data for course ##{@course.id}.",
      failure: "Failed to fetch CSV grade data for course ##{@course.id}."
    }
  end

  def notification_messages
    {
      success: "Grade export notification mailer was successfully delivered.",
      failure: "Grade export notification mailer was not delivered."
    }
  end


end
