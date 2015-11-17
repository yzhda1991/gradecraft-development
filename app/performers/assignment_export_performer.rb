class AssignmentExportPerformer < ResqueJob::Performer
  include ModelAddons::ImprovedLogging # log errors with attributes

  def setup
    fetch_assets
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if work_resources_present?
      require_success(generate_csv_messages, max_result_size: 250) do
        generate_export_csv
      end

      require_success(csv_export_messages) do
        export_csv_successful?
      end
    else
      if logger
        log_error_with_attributes "@assignment.present? or @students.present? failed and both should have been present, could not do_the_work"
      end
    end
  end

  # add this for logging_with_attributes
  def attributes
    { 
      assignment_id: @assignment.try(:id),
      course_id: @course.try(:id),
      professor_id: @professor.try(:id),
      student_ids: @students.collect(&:id),
      team_id: @team.try(:id)
    }
  end

  protected

  def work_resources_present?
    @assignment.present? and @students.present?
  end

  def fetch_assets
    @assignment = fetch_assignment # this should pull in submissions as well
    @course = fetch_course
    @professor = fetch_professor
    @students = fetch_students
    @team = fetch_team if team_present?
    @submissions = fetch_submissions
  end

  def team_present?
    @attrs[:team_id].present?
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir
  end

  def csv_file_path
    @csv_file_path ||= File.expand_path("_grade_import_template.csv", tmp_dir)
  end

  def archive_basename
    if team_present?
      "#{formatted_assignment_name}_#{formatted_team_name}"
    else
      formatted_assignment_name
    end
  end

  # @mz todo: add specs
  def fileized_assignment_name
    @assignment.name
      .downcase
      .gsub(/[^\w\s_-]+/, '') # strip out characters besides letters and digits
      .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2') # remove extra spaces
      .gsub(/\s+/, '_') # replace spaces with underscores
  end

  def sorted_student_directory_keys
    submissions_grouped_by_student.keys.sort
  end

  def export_file_basename
    @export_file_basename ||= "#{fileized_assignment_name}_export_#{Time.now.strftime("%Y-%m-%d")}"
  end

  def submissions_grouped_by_student
    @submissions_grouped_by_student ||= @submissions.group_by do |submission|
      submission.student.formatted_key_name
    end
  end

  def formatted_assignment_name
    formatted_archive_fragment(@assignment.name)
  end

  def formatted_team_name
    formatted_archive_fragment(@team.name)
  end

  def formatted_archive_fragment(fragment)
    "#{fragment.gsub(/\W+/, "_").downcase[0..19]}"
  end

  def fetch_course
    @course = @assignment.course
  end

  def fetch_students
    if team_present?
      @students = @course.students_being_graded_by_team(@team)
    else
      @students = @course.students_being_graded
    end
  end

  def fetch_submissions
    if team_present?
      @submissions = @assignment.student_submissions_for_team(@team)
    else
      @submissions = @assignment.student_submissions
    end
  end
  
  def fetch_assignment
    @assignment = Assignment.find @attrs[:assignment_id]
  end

  def fetch_team
    @team = Team.find @attrs[:team_id]
  end

  def fetch_professor
    @professor = User.find @attrs[:professor_id]
  end

  def generate_export_csv
    open(csv_file_path, 'w') do |f|
      f.puts @assignment.grade_import(@students)
    end
  end

  def export_csv_successful?
    @export_csv_successful ||= File.exist?(csv_file_path)
  end

  private


  def submissions_by_student_archive_hash
    JbuilderTemplate.new(temp_view_context).encode do |json|
      json.partial! "assignment_exports/submissions_by_student_archive_json", presenter: @presenter
    end.to_json
  end

  def submissions_presenter
    @presenter ||= AssignmentExportPresenter.build(presenter_options)
  end

  # @mz todo: add specs
  def presenter_options
   {
      assignment: @assignment,
      csv_file_path: csv_file_path,
      export_file_basename: export_file_basename,
      submissions: @submissions,
      team: @team
    }
  end

  # @mz todo: add specs, add require_success block
  def deliver_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @user, @csv_data).deliver_now
  end

  # @mz todo: add specs, add require_success block
  def deliver_team_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @user, @csv_data).deliver_now
  end

  def generate_csv_messages
    {
      success: "Successfully generated the csv data on assignment #{@assignment.id} for students: #{@students.collect(&:id)}",
      failure: "Failed to generate the csv data on assignment #{@assignment.id} for students: #{@students.collect(&:id)}"
    }
  end

  def csv_export_messages
    {
      success: "Successfully saved the CSV file on disk for assignment #{@assignment.id} for students: #{@students.collect(&:id)}",
      failure: "Failed to save the CSV file on disk for assignment #{@assignment.id} for students: #{@students.collect(&:id)}"
    }
  end

  # @mz todo: add specs, add require_success block
  def notification_messages
    {
      success: "Assignment export notification mailer was successfully delivered.",
      failure: "Assignment export notification mailer was not delivered."
    }
  end
end
