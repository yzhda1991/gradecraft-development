class SubmissionExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
    @filename = @attrs[:filename]
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? && @user.present?
      require_success(fetch_csv_messages, max_result_size: 250) do
       fetch_csv_data(@course)
      end

      require_success(notification_messages, max_result_size: 200) do
        notify_submission_export # the result of this block determines the outcome
      end
    end
  end

  protected

  def fetch_user
    User.find @attrs[:user_id]
  end

  # TODO: speed this up by condensing the CSV generator into a single query
  def fetch_course # TODO: add specs for includes
    Course.includes(:assignments, :assignment_types, submissions: :grade).find @attrs[:course_id]
  end

  def fetch_csv_data(course)
    @csv_data = SubmissionExporter.new.export(course)
  end

  def notify_submission_export
    ExportsMailer
      .submission_export(@course, @user, @filename, @csv_data)
      .deliver_now
  end

  def fetch_csv_messages
    {
      success: "Successfully fetched submission data for course ##{@course.id}.",
      failure: "Failed to fetch submission data for course ##{@course.id}."
    }
  end

  def notification_messages
    {
      success: "Submission export notification mailer was successfully delivered.",
      failure: "Submission export notification mailer was not delivered."
    }
  end
end
