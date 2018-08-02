require "active_lms"
require_relative "../../services/imports_lms_grades"

# rubocop:disable AndOr
class Grades::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action except: [:download, :index, :show, :upload] do |controller|
    controller.redirect_path \
      assignment_grades_importers_path(params[:assignment_id])
  end
  before_action :link_canvas_credentials, except: [:download, :index, :show, :upload],
    if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization, except: [:download, :index, :show, :upload]
  before_action :use_current_course, except: :download

  # GET # /assignments/:assignment_id/grades/importers/:importer_provider_id/assignments
  def assignments
    @assignment = Assignment.find params[:assignment_id]
    @provider_name = params[:importer_provider_id]
  end

  # GET /assignments/:assignment_id/grades/download
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment
  def download
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv do
        send_data GradeExporter.new.export_grades(assignment, current_course.students, true),
          filename: "#{ assignment.name } Import Grades - #{ Date.today}.csv"
      end
    end
  end

  # GET /assignments/:assignment_id/grades/importers/:importer_provider_id/courses/:id/grades
  def grades
    @assignment = Assignment.find params[:assignment_id]
    @provider_name = params[:importer_provider_id]
    @assignment_ids = params[:assignment_ids]
    @course_id = params[:id]
  end

  # POST /assignments/:assignment_id/grades/importers/:importer_provider_id/courses/:id/grades/import
  def grades_import
    @provider_name = params[:importer_provider_id]
    @assignment = Assignment.find params[:assignment_id]

    @result = Services::ImportsLMSGrades.call @provider_name,
      authorization(@provider_name).access_token, params[:id], params[:assignment_ids],
      params[:grade_ids], @assignment, current_user

    if @result.success?
      render :grades_import_results
    else
      @grades = syllabus.grades(params[:id], params[:assignment_ids]) do
        redirect_to assignment_grades_importers_path(@assignment),
          alert: "There was an issue trying to retrieve the grades from #{@provider_name.capitalize}." and return
      end[:data]

      render :grades, alert: @result.message
    end
  end

  # GET /assignments/:assignment_id/grades/importers
  def index
    @assignment = Assignment.find params[:assignment_id]
  end

  # GET /assignments/:assignment_id/grades/importers/:id
  def show
    @assignment = Assignment.find params[:assignment_id]
    provider = params[:provider_id]

    render "#{provider}" if %w(canvas csv).include? provider
  end

  # POST /assignments/:assignment_id/grades/importers/:importer_provider_id/upload
  # rubocop:disable AndOr
  def upload
    @assignment = @course.assignments.find(params[:assignment_id])

    if params[:file].blank?
      redirect_to assignment_grades_importer_path(@assignment, params[:importer_provider_id]),
        notice: "File is missing" and return
    end

    if (File.extname params[:file].original_filename) != ".csv"
      redirect_to assignment_grades_importer_path(@assignment, params[:importer_provider_id]),
        notice: "We're sorry, the grade import utility only supports .csv files. Please try again using a .csv file." and return
    end

    @result = CSVGradeImporter.new(params[:file].tempfile)
      .import(current_course, @assignment)

    grade_ids = @result.successful.map(&:id)
    enqueue_multiple_grade_update_jobs(grade_ids)

    render :import_results
  end

  private

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end
end
