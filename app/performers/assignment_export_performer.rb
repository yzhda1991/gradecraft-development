class AssignmentExportPerformer < ResqueJob::Performer
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

  # @mz todo: add specs
  def generate_export_csv
    # there needs to be a good way to determine the difference between data pulled from the remote sources vs. local ones
    csv_dir = Dir.mktmpdir
    @csv_file_path = File.expand_path(csv_dir, "/_grade_import_template.csv")
    open( @csv_file_path,'w' ) do |f|
      f.puts @assignment.grade_import(@students) # need to pull @students out of @submissions_by_student
    end
  end
  
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
      success: "Assignment export notification mailer was successfully delivered.",
      failure: "Assignment export notification mailer was not delivered."
    }
  end
end
