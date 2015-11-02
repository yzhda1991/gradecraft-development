class AssignmentExportPerformer < ResqueJob::Performer
  def setup
    @user = fetch_user
    @course = fetch_course
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @course.present? and @user.present?
      require_success(fetch_csv_messages, max_result_size: 250) do
        generate_export_csv
      end

      require_success(notification_messages, max_result_size: 200) do
        notify_gradebook_export # the result of this block determines the outcome
      end
    end
  end

  private

  def submissions_presenter
    @presenter ||= AssignmentExportPresenter.build(
      presenter_base_options.merge(
        submissions: @assignment.student_submissions
      )
    )
  end

  def assignment_export_attributes
    {
      assignment_id: params[:assignment_id],
      team_id: params[:team_id]
    }
  end

  def submissions_by_student_archive_hash
    JbuilderTemplate.new(temp_view_context).encode do |json|
      json.partial! "assignment_exports/submissions_by_student_archive_json", presenter: @presenter
    end.to_json
  end

  def submissions_by_team_presenter
    @presenter ||= AssignmentExportPresenter.build(
      presenter_base_options.merge(
        submissions: @assignment.student_submissions_for_team(@team),
        team: @team
      )
    )
  end

  def submissions_presenter
    @presenter ||= AssignmentExportPresenter.build(
      presenter_base_options.merge(
        submissions: @assignment.student_submissions
      )
    )
  end

  def presenter_base_options
   {
      assignment: @assignment,
      csv_file_path: @csv_file_path,
      export_file_basename: export_file_basename
    }
  end

  # rough this in for now, need to pull this from the original method
  def export_file_basename
    "great_basename"
  end

  def fetch_assignment
    @assignment = Assignment.find params[:assignment_id]
  end

  def fetch_team
    @team = Team.find params[:team_id]
  end

  # @mz todo: add specs
  def generate_export_csv
    # there needs to be a good way to determine the difference between data pulled from the remote sources vs. local ones
    csv_dir = Dir.mktmpdir
    @csv_file_path = File.expand_path(csv_dir, "/_grade_import_template.csv")
    open( @csv_file_path,'w' ) do |f|
      f.puts @assignment.grade_import(@students) # need to pull @students out of @submissions_by_student
    end
  end
  
  def deliver_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @user, @csv_data).deliver_now
  end

  def deliver_team_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @user, @csv_data).deliver_now
  end

  def notification_messages
    {
      success: "Assignment export notification mailer was successfully delivered.",
      failure: "Assignment export notification mailer was not delivered."
    }
  end
end
