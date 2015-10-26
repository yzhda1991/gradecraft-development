class GradebookExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success(fetch_csv_messages, max_result_size: 250) do
        fetch_csv_data
      end

      require_success(notification_messages, max_result_size: 200) do
        notify_gradebook_export # the result of this block determines the outcome
      end
    end
  end

  private
  
  def fetch_user
    User.find @attrs[:user_id]
  end

  # todo: speed this up by condensing the CSV generator into a single query
  def fetch_course # TODO: add specs for includes
    Course.find @attrs[:course_id]
  end

  # todo spec
  def sanitized_csv_excerpt
    fetch_csv_data.gsub("\n","").split(//).last(50).join
  end

  def fetch_csv_data
    @csv_data = @course.csv_gradebook
  end

  def notify_gradebook_export
    NotificationMailer.gradebook_export(@course, @user, @csv_data).deliver_now
  end

  def fetch_csv_messages
    {
      success: "Successfully fetched CSV gradebook data for course ##{@course.id}.",
      failure: "Failed to fetch CSV gradebook data for course ##{@course.id}."
    }
  end

  def notification_messages
    {
      success: "Gradebook export notification mailer was successfully delivered.",
      failure: "Gradebook export notification mailer was not delivered."
    }
  end
end
