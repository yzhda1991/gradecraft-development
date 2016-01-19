class SubmissionsExportPerformer < ResqueJob::Performer
  require 'fileutils' # need this for mkdir_p
  require 'open-uri' # need this for getting the S3 file over http
  include ModelAddons::ImprovedLogging # log errors with attributes

  attr_reader :submissions_export

  def setup
    ensure_s3fs_tmp_dir if use_s3fs?
    @submissions_export = SubmissionsExport.find @attrs[:submissions_export_id]
    fetch_assets
    @submissions_export.update_attributes submissions_export_attributes
    @errors = []
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if work_resources_present?
      # generate the csv overview for the assignment or team
      require_success(generate_csv_messages, max_result_size: 250) do
        generate_export_csv
        @submissions_export.update_attributes generate_export_csv: true
      end

      # check whether the csv export was successful
      require_success(csv_export_messages) do
        @submissions_export.update_attributes export_csv_successful: true
        export_csv_successful?
      end

      # generate student directories
      require_success(create_student_directory_messages) do
        @submissions_export.update_attributes create_student_directories: true
        create_student_directories
      end

      # check whether the student directories were all created successfully
      require_success(check_student_directory_messages) do
        @submissions_export.update_attributes student_directories_created_successfully: true
        student_directories_created_successfully?
      end

      # create text files in each student directory if there is submission data that requires it
      require_success(create_submission_text_file_messages) do
        @submissions_export.update_attributes create_submission_text_files: true
        create_submission_text_files
      end

      # create binary files in each student directory
      require_success(create_submission_binary_file_messages) do
        @submissions_export.update_attributes create_submission_binary_files: true
        create_submission_binary_files
        write_note_for_missing_binary_files
      end

      # create binary files in each student directory
      require_success(remove_empty_student_directories_messages) do
        @submissions_export.update_attributes remove_empty_student_directories: true
        remove_empty_student_directories
      end

      # write error log for errors that may have occurred during file generation
      require_success(generate_error_log_messages) do
        @submissions_export.update_attributes generate_error_log: true
        generate_error_log
      end

      require_success(archive_exported_files_messages) do
        @submissions_export.update_attributes archive_exported_files: true
        archive_exported_files
      end

      require_success(upload_archive_to_s3_messages) do
        @submissions_export.update_attributes upload_archive_to_s3: true
        upload_archive_to_s3
      end

      require_success(check_s3_upload_success_messages) do
        @submissions_export.update_attributes check_s3_upload_success: true
        check_s3_upload_success
      end

      deliver_outcome_mailer
      @submissions_export.update_export_completed_time
    else
      if logger
        log_error_with_attributes "@assignment.present? and/or @students.present? failed and both should have been present, could not do_the_work"
      end
    end
  end

  def submissions_export_attributes
    if @submissions_export.last_export_started_at
      base_export_attributes.merge(clear_progress_attributes)
    else
      base_export_attributes
    end
  end

  def base_export_attributes
    {
      student_ids: @students.collect(&:id),
      submissions_snapshot: submissions_snapshot,
      export_filename: "#{export_file_basename}.zip",
      last_export_started_at: Time.now
    }
  end
  alias_method :attributes, :base_export_attributes

  def clear_progress_attributes
    {
      generate_export_csv: nil,
      export_csv_successful: nil,
      create_student_directories: nil,
      student_directories_created_successfully: nil,
      create_submission_text_files: nil,
      create_submission_binary_files: nil,
      generate_error_log: nil,
      remove_empty_student_directories: nil,
      archive_exported_files: nil,
      upload_archive_to_s3: nil,
      check_s3_upload_success: nil
    }
  end

  protected

  def work_resources_present?
    @assignment.present? and @students.present?
  end

  def fetch_assets
    @assignment = @submissions_export.assignment
    @course = @submissions_export.course
    @professor = @submissions_export.professor
    @team = @submissions_export.team
    @students = fetch_students
    @students_for_csv = fetch_students_for_csv
    @submissions = fetch_submissions
  end

  def team_present?
    @submissions_export[:team_id].present?
  end

  def s3_manager
    @s3_manager ||= @submissions_export.s3_manager || S3Manager::Manager.new
  end

  def tmp_dir
    if use_s3fs?
      @tmp_dir ||= Dir.mktmpdir(nil, s3fs_tmp_dir_path)
    else
      @tmp_dir ||= Dir.mktmpdir
    end
  end

  def csv_file_path
    @csv_file_path ||= File.expand_path("_grade_import_template.csv", tmp_dir)
  end

  def sorted_student_directory_keys
    submissions_grouped_by_student.keys.sort
  end

  def submissions_grouped_by_student
    @submissions_grouped_by_student ||= @submissions.group_by do |submission|
      student_directory_names[submission.student.id]
    end
  end

  def submissions_snapshot
    @submissions_snapshot ||= @submissions.inject({}) do |memo, submission|
      memo[submission.id] = {
        student_id: submission.student_id,
        updated_at: submission.updated_at.to_s
      }
      memo
    end
  end

  # methods for building and formatting the archive filename
  def export_file_basename
    @export_file_basename ||= "#{archive_basename} - #{filename_timestamp}"
  end

  # @mz todo: update specs
  def filename_timestamp
    filename_time.strftime("%Y-%m-%d - %l:%M:%S%P").gsub("\s+"," ")
  end

  def filename_time
    @filename_time ||= Time.now
  end

  def archive_basename
    if team_present?
      "#{formatted_assignment_name} - #{formatted_team_name}"
    else
      formatted_assignment_name
    end
  end

  def formatted_assignment_name
    formatted_filename_fragment(@assignment.name)
  end

  def formatted_team_name
    formatted_filename_fragment(@team.name)
  end

  def formatted_filename_fragment(fragment)
    titleize_filename(fragment)
  end

  def titleize_filename(filename)
    filename
      .downcase
      .gsub(/[^\w\s_-]+/, '') # strip out characters besides letters and digits
      .gsub(/_+/, ' ') # replace underscores with spaces
      .gsub(/ +/, ' ') # replace underscores with spaces
      .gsub(/^ +/, '') # remove leading spaces
      .gsub(/ +$/, '') # remove trailing spaces
      .titleize
  end

  def sanitize_filename(filename)
    filename
      .downcase
      .gsub(/[^\w\s_-]+/, '') # strip out characters besides letters and digits
      .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2') # remove extra spaces
      .gsub(/\s+/, '_') # replace spaces with underscores
      .gsub(/^_+/, '') # remove leading underscores
      .gsub(/_+$/, '') # remove trailing underscores
  end

  def fetch_course
    @course = @assignment.course
  end

  def fetch_students_for_csv
    if team_present?
      @students_for_csv = User.students_by_team(@course, @team)
    else
      @students_for_csv = User.with_role_in_course("student", @course)
    end
  end

  def fetch_students
    if team_present?
      @students = @assignment.students_with_text_or_binary_files_on_team(@team)
    else
      @students = @assignment.students_with_text_or_binary_files
    end
  end

  def fetch_submissions
    if team_present?
      @submissions = @assignment.student_submissions_with_files_for_team(@team)
    else
      @submissions = @assignment.student_submissions_with_files
    end
  end
  
  def fetch_assignment
    @assignment = Assignment.find @attrs[:assignment_id]
  end

  def fetch_team
    @team = Team.find @submissions_export[:team_id]
  end

  def fetch_professor
    @professor = User.find @attrs[:professor_id]
  end

  def generate_export_csv
    open(csv_file_path, 'w') do |f|
      f.puts @assignment.grade_import(@students_for_csv)
    end
  end

  def export_csv_successful?
    @export_csv_successful ||= File.exist?(csv_file_path)
  end

  # final archive concerns

  # create a separate tmp dir for storing the final generated archive
  def ensure_s3fs_tmp_dir
    FileUtils.mkdir_p(s3fs_tmp_dir_path) unless Dir.exist?(s3fs_tmp_dir_path)
  end

  def archive_tmp_dir
    if use_s3fs?
      @archive_tmp_dir ||= Dir.mktmpdir(nil, s3fs_tmp_dir_path)
    else
      @archive_tmp_dir ||= Dir.mktmpdir
    end
  end

  def tmp_dir_parent_path
    use_s3fs? ? s3fs_tmp_dir_path : nil
  end

  def s3fs_tmp_dir_path
    "/s3mnt/tmp/#{Rails.env}"
  end

  def use_s3fs?
    @use_s3fs ||= Rails.env.staging? || Rails.env.production?
  end

  def expanded_archive_base_path
    @expanded_archive_base_path ||= File.expand_path(export_file_basename, archive_tmp_dir)
  end

  ## creating student directories
  
  def student_directories_created_successfully?
    missing_student_directories.empty?
  end

  def missing_student_directories
    @students.inject([]) do |memo, student|
      memo << student_directory_names[student.id] unless Dir.exist?(student_directory_path(student))
      memo
    end
  end

  # in the format of { student_id => "lastname_firstname(--username-if-naming-conflict)" }
  def student_directory_names
    @student_directory_names ||= @students.inject({}) do |memo, student|
      # check to see whether there are any duplicate student names
      if @students.count {|compared_student| student.same_name_as?(compared_student) } > 1
        memo[student.id] = student.alphabetical_name_key_with_username
      else
        memo[student.id] = student.alphabetical_name_key
      end
      memo
    end
  end

  def create_student_directories
    @students.each do |student|
      dir_path = student_directory_path(student)
      FileUtils.mkdir_p(dir_path) # unless Dir.exist?(dir_path) # create directory with parents
    end
  end

  # removing student directories

  def remove_empty_student_directories
    @students.each do |student|
      if student_directory_empty?(student)
        Dir.delete student_directory_path(student)
      end
    end
  end

  def student_directory_empty?(student)
    (Dir.entries(student_directory_path(student)) - %w{ . .. }).empty?
  end

  def student_directory_path(student)
    File.expand_path(student_directory_names[student.id], tmp_dir)
  end

  def create_submission_text_files
    @submissions.each do |submission|
      if submission.text_comment.present? or submission.link.present? # write the text file for the submission into the student export directory
        create_submission_text_file(submission)
      end
    end
  end

  def create_submission_text_file(submission)
    open(submission_text_file_path(submission.student), 'w') do |f|
      f.puts "Submission items from #{submission.student.last_name}, #{submission.student.first_name}"

      if submission.text_comment.present?
        f.puts "\ntext comment: #{submission.text_comment}"
      end

      if submission.link.present?
        f.puts "\nlink: #{submission.link}"
      end
    end
  end

  def submission_text_file_path(student)
    File.expand_path(submission_text_filename(student), student_directory_path(student))
  end

  def submission_text_filename(student)
    [ formatted_student_name(student), formatted_assignment_name, "Submission Text.txt" ].join(" - ")
  end

  # @mz todo: update specs
  def formatted_student_name(student)
    titleize_filename student.full_name
  end

  def create_submission_binary_files
    @submissions.each do |submission|
      if submission.submission_files.present?
        submission.process_unconfirmed_files if submission.submission_files.unconfirmed.count > 0
        create_binary_files_for_submission(submission) 
      end
    end
  end

  def missing_binaries_file_path
    File.expand_path("missing_files.txt", tmp_dir)
  end

  def submission_files_with_missing_binaries
    @submission_files_with_missing_binaries ||= @assignment.submission_files_with_missing_binaries
  end

  def students_with_missing_binaries
    @students_with_missing_binaries ||= @assignment.students_with_missing_binaries
  end

  # @mz todo: update specs
  def write_note_for_missing_binary_files
    unless students_with_missing_binaries.empty?
      open(missing_binaries_file_path, 'wt') do |f|
        f.puts "The following files were uploaded, but no longer appear to be available on the server:"
        students_with_missing_binaries.each_with_index do |student, index|
          f.puts "\n#{student.full_name}:"
          submission_files_with_missing_binaries.each do |missing_file|
            f.puts "#{missing_file.filename}" if missing_file.submission.student_id == student.id
          end
        end
      end
    end
  end

  def create_binary_files_for_submission(submission)
    submission.submission_files.present.each_with_index do |submission_file, index|
      write_submission_binary_file(submission.student, submission_file, index)
    end
  end

  def student_directory_file_path(student, filename)
    File.expand_path(filename, student_directory_path(student))
  end

  def submission_binary_file_path(student, submission_file, index)
    filename = submission_binary_filename(student, submission_file, index)
    student_directory_file_path(student, filename)
  end

  # @mz todo: update specs
  def submission_binary_filename(student, submission_file, index)
    [ formatted_student_name(student), formatted_assignment_name, "Submission File #{index + 1}"].join(" - ") + submission_file.extension
  end

  def write_submission_binary_file(student, submission_file, index)
    file_path = submission_binary_file_path(student, submission_file, index)
    if Rails.env.development?
      submission_file.write_source_binary_to_path(file_path)
    else
      stream_s3_file_to_disk(submission_file, file_path)
    end
  end

  def stream_s3_file_to_disk(submission_file, target_file_path)
    begin
      s3_manager.write_s3_object_to_disk(submission_file.s3_object_file_key, target_file_path)
    rescue Aws::S3::Errors::NoSuchKey
      submission_file.mark_file_missing
    end
  end

  def remove_if_exists(file_path)
    File.delete file_path if File.exist? file_path
  end

  def binary_file_error_message(message, student, submission_file, error_io)
    "#{message}. Student ##{student.id}: #{student.last_name}, #{student.first_name}, " + 
    "SubmissionFile ##{submission_file.id}: #{submission_file.filename}, error: #{error_io}"
  end

  # @mz todo: modify specs
  def generate_error_log
    unless @errors.empty?
      open(error_log_path, 'w') {|file| file.puts @errors }
    end
  end

  def error_log_path
    File.expand_path("error_log.txt", tmp_dir)
  end

  # archive export directory
  def archive_exported_files
    # `zip -r - #{tmp_dir} | pv -L 200k > #{expanded_archive_base_path}.zip`
    Archive::Zip.archive("#{expanded_archive_base_path}.zip", tmp_dir)
  end

  def upload_archive_to_s3
    @submissions_export.upload_file_to_s3("#{expanded_archive_base_path}.zip")
  end

  def check_s3_upload_success
    @check_s3_upload_success ||= @submissions_export.s3_object_exists?
  end

  private

  def deliver_outcome_mailer
    if check_s3_upload_success
      deliver_archive_success_mailer
    else
      deliver_archive_failed_mailer
    end
  end

  def deliver_archive_success_mailer
    @team ? deliver_team_export_successful_mailer : deliver_export_successful_mailer
  end

  def deliver_archive_failed_mailer
    @team ? deliver_team_export_failure_mailer : deliver_export_failure_mailer
  end

  def deliver_export_successful_mailer
    ExportsMailer.submissions_export_success(@professor, @assignment).deliver_now
  end

  def deliver_team_export_successful_mailer
    ExportsMailer.team_submissions_export_success(@professor, @assignment, @team).deliver_now
  end

  def deliver_export_failure_mailer
    ExportsMailer.submissions_export_failure(@professor, @assignment).deliver_now
  end

  def deliver_team_export_failure_mailer
    ExportsMailer.team_submissions_export_failure(@professor, @assignment, @team).deliver_now
  end

  def expand_messages(messages={})
    {
      success: [ messages[:success], message_suffix ].join(" "),
      failure: [ messages[:failure], message_suffix ].join(" ")
    }
  end

  def generate_export_json_messages
    expand_messages ({
      success: "Successfully generated the export JSON",
      failure: "Failed to generate the export JSON"
    })
  end

  def generate_csv_messages
    expand_messages({
      success: "Successfully generated the csv data",
      failure: "Failed to generate the csv data"
    })
  end

  def csv_export_messages
    expand_messages ({
      success: "Successfully saved the CSV file on disk",
      failure: "Failed to save the CSV file on disk"
    })
  end

  def create_student_directory_messages
    expand_messages ({
      success: "Successfully created the student directories",
      failure: "Failed to create the student directories"
    })
  end

  def check_student_directory_messages
    expand_messages ({
      success: "Successfully confirmed creation of all student directories",
      failure: "Some student directories did not create properly"
    })
  end

  def create_submission_text_file_messages
    expand_messages ({
      success: "Successfully created all text files for the student submissions",
      failure: "Student submission text files did not create properly"
    })
  end

  def create_submission_binary_file_messages
    expand_messages ({
      success: "Successfully created all binary files for the student submissions",
      failure: "Student submission binary files did not create properly"
    })
  end

  def generate_error_log_messages
    expand_messages ({
      success: "Successfully generated an error log for binary file creation if one was required",
      failure: "Failed to build an error log for binary file creation errors"
    })
  end

  def archive_exported_files_messages
    expand_messages ({
      success: "Successfully generated an archive containing the exported assignment files",
      failure: "Failed to generate an archive containing the exported assignment files"
    })
  end

  def upload_archive_to_s3_messages
    expand_messages ({
      success: "Successfully uploaded the submissions archive to S3",
      failure: "Failed to upload the submissions archive to S3"
    })
  end

  def remove_empty_student_directories_messages
    expand_messages ({
      success: "Successfully removed empty student directories from archive",
      failure: "Failed to remove empty student directories"
    })
  end

  def check_s3_upload_success_messages
    expand_messages ({
      success: "Successfully confirmed that the exported archive was uploaded to S3",
      failure: "Failed to confirm that the exported archive was uploaded to S3. ObjectSummary#exists? failed on the object instance."
    })
  end

  def message_suffix
    "for assignment #{@assignment.id} for students: #{@students.collect(&:id)}"
  end
end
