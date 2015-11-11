class AssignmentExportPerformer < ResqueJob::Performer
  include ModelAddons::ImprovedLogging # log errors with attributes

  def setup
    cache_assets
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if @assignment.present? and @students.present?
      require_success(generate_csv_messages, max_result_size: 250) do
        generate_export_csv
      end
    else
      log_error_with_attributes "@assignment.present? or @students.present? failed and both should have been present"
    end
  end

  protected

  def cache_assets
    assignment; course; professor; team; students
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir
  end

  def csv_file_path
    @csv_file_path ||= File.expand_path(@tmp_dir, "/_grade_import_template.csv")
  end

  # # entire block handled by submissions and submissions_by_team methods, and by 
  # if params[:team_id].present?
  #   team = current_course.teams.find_by(id: params[:team_id])
  #   zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_#{team.name}"
  #   @students = current_course.students_being_graded_by_team(team)
  # else
  #   zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}"
  #   @students = current_course.students_being_graded
  # end
  #
  def course
    @course ||= assignment.course
  end

  def students
    if @attrs[:team_id].present?
      @students ||= course.students_being_graded_by_team(team)
    end
  end

  def assignment
    @assignment ||= Assignment.find @attrs[:assignment_id]
  end

  def team
    @team ||= Team.find @attrs[:team_id]
  end

  def professor
    @professor ||= User.find @attrs[:professor_id]
  end

  def generate_export_csv
    open(@csv_file_path, 'w') do |f|
      f.puts @assignment.grade_import(@students)
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
      assignment_id: @attrs[:assignment_id],
      team_id: @attrs[:team_id]
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

  def deliver_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @user, @csv_data).deliver_now
  end

  def deliver_team_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @user, @csv_data).deliver_now
  end

  def generate_csv_messages
    {
      success: "Successfully generated the csv data on assignment #{@assignment.id} for students: #{@students.collect(&:id)}",
      failure: "Failed to generate the csv data on assignment #{@assignment.id} for students: #{@students.collect(&:id)}"
    }
  end

  def notification_messages
    {
      success: "Assignment export notification mailer was successfully delivered.",
      failure: "Assignment export notification mailer was not delivered."
    }
  end
end
