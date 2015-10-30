class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?
  before_filter :fetch_assignment
  before_filter :fetch_team, only: :submissions_by_team
  before_filter :generate_export_csv

  respond_to :json

  def submissions
    @presenter = params[:team_id] ? submissions_by_team_presenter :  submissions_presenter
    @archive_json = submissions_by_student_archive_hash
    respond_with @archive.start_archive_with_compression # should return json { status: 200, message: "Your requested export is being assembled, find it here: http://gc.com/download" }
  end

  def export_submissions
    @students ||= students_for_submission_export
  end

  def export_team_submissions
    @students_on_team ||=  students_for_team_submission_export
  end

  private
    def assignment_export_attributes
      {
        assignment_id: params[:assignment_id],
        team_id: params[:team_id]
      }
    end

    # @mz todo: add specs for this nonsense
    def build_archive_and_queue_build_jobs
      @archive = SmartArchiver::Archive.new(json: archive_json, name: archive_name, max_cpu_usage: 0.2)
      @archive.assemble_directories_on_disk # build the directory structure and create file-getting jobs
      @archive.archive_with_compression # create tar job for directory
      @archive.clean_tmp_dir_on_complete # create job for removing the tmp directory on completion
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
end
