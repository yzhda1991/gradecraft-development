class GradebookExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success(messages) do
        fetch_csv_data
        puts "Fetched CSV data: #'#{sanitized_csv_excerpt}...'" # TODO: add spec
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

  def messages
    {
      success: "Gradebook export notification mailer was successfully delivered.",
      failure: "Gradebook export notification mailer was not delivered."
    }
  end
end
