class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?
  before_filter :fetch_assignment
  before_filter :fetch_team, only: :submissions_by_team
  before_filter :assemble_json_for_archiver
  before_filter :generate_export_csv

  respond_to :json

  def submissions
    @presenter = submissions_presenter
    @archive = Backstacks::Archive.new(submissions_by_student_archive_json)
    @archive.assemble
    respond_with @archive.start_archive_with_compression # should return json { status: 200, message: "Your requested export is being assembled, find it here: http://gc.com/download" }
  end

  def submissions_presenter,submissions_by_team
    @presenter = submissions_by_team_presenter
    @archive = Backstacks::Archive.new(submissions_by_student_team_archive_json)
    @archive.assemble
    respond_with @archive.start_archive_with_compression # should return json { status: 200, message: "Your requested export is being assembled, find it here: http://gc.com/download" }
  end

  def export
    fetch_assignment
    @submissions ||= @assignment.student_submissions
    group_submissions_by_student
  end

  private

    def submissions_by_student_archive_hash
      JbuilderTemplate.new(temp_view_context).encode do |json|
        json.partial! "assignment_exports/submissions_by_student_archive_json",
          presenter: @presenter
      end.to_json
    end

    # needs specs
    def generate_export_csv
      open( "#{export_dir}/_grade_import_template.csv",'w' ) do |f|
        f.puts @assignment.grade_import(@students) # need to pull @students out of @submissions_by_student
      end
    end

    def submissions_by_team_presenter
      @presenter ||= AssignmentExportPresenter.build({
        submissions: @assignment.student_submissions_for_team(@team),
        assignment: @assignment,
        team: @team
      })
    end

    def submissions_presenter
      @presenter ||= AssignmentExportPresenter.build({
        submissions: @assignment.student_submissions,
        assignment: @assignment
      })
    end

    def fetch_assignment
      @assignment = Assignment.find params[:assignment_id]
    end

    def fetch_team
      @team = Team.find params[:team_id]
    end
end
