class AssignmentExportPerformer < ResqueJob::Performer
  require 'fileutils' # need this for mkdir_p
  require 'open-uri' # need this for getting the S3 file over http
  include ModelAddons::ImprovedLogging # log errors with attributes

  def setup
    fetch_assets
    
    # @mz todo: add specs
    @errors = []
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    if work_resources_present?
      # generate the csv overview for the assignment or team
      require_success(generate_csv_messages, max_result_size: 250) do
        generate_export_csv
      end

      # check whether the csv export was successful
      require_success(csv_export_messages) do
        export_csv_successful?
      end

      # generate student directories
      require_success(create_student_directory_messages) do
        create_student_directories
      end

      # check whether the student directories were all created successfully
      require_success(check_student_directory_messages) do
        student_directories_created_successfully?
      end

      require_success(create_submission_text_file_messages) do
        create_submission_text_files
      end

      require_success(create_submission_binary_file_messages) do
        create_submission_binary_files
      end

      # require_sucess(start_archive_messages) do
      #   start_archive_process
      # end
    else
      if logger
        log_error_with_attributes "@assignment.present? and/or @students.present? failed and both should have been present, could not do_the_work"
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

  def sorted_student_directory_keys
    submissions_grouped_by_student.keys.sort
  end

  def submissions_grouped_by_student
    @submissions_grouped_by_student ||= @submissions.group_by do |submission|
      submission.student.formatted_key_name
    end
  end

  # methods for building and formatting the archive filename
  def export_file_basename
    @export_file_basename ||= "#{archive_basename}_export_#{Time.now.strftime("%Y-%m-%d")}"
  end

  def archive_basename
    if team_present?
      "#{formatted_assignment_name}_#{formatted_team_name}"
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
    sanitize_filename(fragment).slice(0..24) # take only 25 characters
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

  # final archive concerns

  # create a separate tmp dir for storing the final generated archive
  def archive_tmp_dir
    @archive_tmp_dir ||= Dir.mktmpdir
  end

  def expanded_archive_base_path
    @expanded_archive_base_path ||= File.expand_path(export_file_basename, archive_tmp_dir)
  end

  # @mz todo: add specs
  def start_archive_process
    case @archive_type
    when :zip
      `zip -r - #{tmp_dir} | pv -L #{@rate_limit} > #{expanded_archive_base_path}.zip`
    when :tar
      `tar czvf - #{tmp_dir} | pv -L #{@rate_limit} > #{expanded_archive_base_path}.tgz`
    end
  end

  ## creating student directories
  
  def student_directories_created_successfully?
    missing_student_directories.empty?
  end

  def missing_student_directories
    @students.inject([]) do |memo, student|
      memo << student.formatted_key_name unless Dir.exist?(student_directory_path(student))
      memo
    end
  end

  def create_student_directories
    @students.each do |student|
      dir_path = student_directory_path(student)
      FileUtils.mkdir_p(dir_path) # unless Dir.exist?(dir_path) # create directory with parents
    end
  end

  def student_directory_path(student)
    File.expand_path(student.formatted_key_name, tmp_dir)
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
    [ formatted_student_name(student), formatted_assignment_name, "submission_text.txt" ].join("_")
  end

  def formatted_student_name(student)
    sanitize_filename("#{student.first_name}_#{student.last_name}")
  end

  def create_submission_binary_files
    @submissions.each do |submission|
      create_binary_files_for_submission(submission) if submission.submission_files.present?
    end
  end

  # @mz todo: add specs
  def create_binary_files_for_submission(submission)
    submission.submission_files.each_with_index do |submission_file, index|
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

  def submission_binary_filename(student, submission_file, index)
    [ formatted_student_name(student), formatted_assignment_name, "submission_file#{index}"].join("_") + submission_file.extension
  end

  def write_submission_binary_file(student, submission_file, index)
    file_path = submission_binary_file_path(student, submission_file, index)

    rescue_binary_file_exceptions(student, submission_file, file_path) do
      open(file_path, 'w') {|file| file.binmode; file.write open(submission_file.url).read }
    end
  end

  def rescue_binary_file_exceptions(student, submission_file, file_path)
    begin
      yield
    rescue OpenURI::HTTPError => error
      @errors << binary_file_error_message("Invalid URL for file", student, submission_file, error.io)
      remove_if_exists file_path
    end
  end

  def remove_if_exists(file_path)
    File.delete file_path if File.exist? file_path
  end

  # @mz todo: add specs
  def binary_file_error_message(message, student, submission_file, error_io)
    "#{message}. Student ##{student.id}: #{student.last_name}, #{student.first_name}, " + 
    "SubmissionFile ##{submission_file.id}: #{submission_file.filename}, error: #{error_io}"
  end

  private

  # @mz todo: add specs, add require_success block
  def deliver_archive_complete_mailer
    ExportsMailer.submissions_archive_complete(@course, @professor, @csv_data).deliver_now
  end

  # @mz todo: add specs, add require_success block
  def deliver_team_archive_complete_mailer
    ExportsMailer.team_submissions_archive_complete(@course, @professor, @csv_data).deliver_now
  end

  # @mz todo: modify specs
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

  # @mz todo: add specs
  def csv_export_messages
    expand_messages ({
      success: "Successfully saved the CSV file on disk",
      failure: "Failed to save the CSV file on disk"
    })
  end

  # @mz todo: add specs
  def create_student_directory_messages
    expand_messages ({
      success: "Successfully created the student directories",
      failure: "Failed to create the student directories"
    })
  end

  # @mz todo: add specs
  def check_student_directory_messages
    expand_messages ({
      success: "Successfully confirmed creation of all student directories",
      failure: "Some student directories did not create properly"
    })
  end

  # @mz todo: add specs
  def create_submission_text_file_messages
    expand_messages ({
      success: "Successfully created all text files for the student submissions",
      failure: "Student submission text files did not create properly"
    })
  end

  # @mz todo: add specs
  def create_submission_binary_file_messages
    expand_messages ({
      success: "Successfully created all binary files for the student submissions",
      failure: "Student submission binary files did not create properly"
    })
  end

  def message_suffix
    "for assignment #{@assignment.id} for students: #{@students.collect(&:id)}"
  end
end
