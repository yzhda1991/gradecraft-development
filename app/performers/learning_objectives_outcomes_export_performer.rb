class LearningObjectivesOutcomesExportPerformer < ResqueJob::Performer
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
        notify_learning_objectives_outcomes_export
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

  def fetch_csv_data(course)
    @csv_data = LearningObjectivesOutcomesExporter.new(course).learning_objective_outcomes
  end

  def notify_learning_objectives_outcomes_export
    ExportsMailer
      .learning_objectives_outcomes_exporter(@course, @user, @filename, @csv_data)
      .deliver_now
  end

  def fetch_csv_messages
    {
      success: "Successfully fetched CSV learning objectives outcomes data for course ##{@course.id}.",
      failure: "Failed to fetch CSV learning objectives outcomes data for course ##{@course.id}."
    }
  end

  def notification_messages
    {
      success: "Learning objectives outcomes exporter notification mailer was successfully delivered.",
      failure: "Learning objectives outcomes exporter notification mailer was not delivered."
    }
  end
end
