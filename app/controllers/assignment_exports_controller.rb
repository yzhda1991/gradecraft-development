class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?
  before_filter :fetch_assignment
  before_filter :fetch_team, only: :submissions_by_team
  before_filter :assemble_json_for_archiver
  before_filter :generate_export_csv

  respond_to :json

  def submissions
    @presenter = submissions_presenter
    @archive_json submissions_by_student_archive_hash
    build_archive_and_queue_build_jobs
    respond_with @archive.start_archive_with_compression # should return json { status: 200, message: "Your requested export is being assembled, find it here: http://gc.com/download" }
  end

  def submissions_presenter,submissions_by_team
    @presenter = submissions_by_team_presenter
    @archive_json submissions_by_student_archive_hash
    build_archive_and_queue_build_jobs
    respond_with @archive.start_archive_with_compression # should return json { status: 200, message: "Your requested export is being assembled, find it here: http://gc.com/download" }
  end

  def export
    fetch_assignment
    @submissions ||= @assignment.student_submissions
    group_submissions_by_student
  end

  private

    def build_archive_and_queue_build_jobs
      @archive = Backstacks::Archive.new(json: archive_json, name: archive_name, max_cpu_usage: 0.2)
      @archive.assemble_directories_on_disk # build the directory structure and create file-getting jobs
      @archive.archive_with_compression # create tar job for directory
      @archive.clean_tmp_dir_on_complete # create job for removing the tmp directory on completion
    end

    def submissions_by_student_archive_hash
      JbuilderTemplate.new(temp_view_context).encode do |json|
        json.partial! "assignment_exports/submissions_by_student_archive_json",
          presenter: @presenter
      end.to_json
    end

    # needs specs
    def generate_export_csv
      # there needs to be a good way to determine the difference between data pulled from the remote sources vs. local ones
      csv_dir = Dir.mktmpdir
      @csv_file_path = File.expand_path(csv_dir, "/_grade_import_template.csv")
      open( @csv_file_path,'w' ) do |f|
        f.puts @assignment.grade_import(@students) # need to pull @students out of @submissions_by_student
      end
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
          submissions: @assignment.student_submissions,
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

    def fetch_assignment
      @assignment = Assignment.find params[:assignment_id]
    end

    def fetch_team
      @team = Team.find params[:team_id]
    end
end
