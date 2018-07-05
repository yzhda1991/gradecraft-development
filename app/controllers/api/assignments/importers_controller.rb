require_relative "../../../importers/assignment_importers/csv_assignment_importer"

# rubocop:disable AndOr
class API::Assignments::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action :link_canvas_credentials, except: [:upload, :import],
    if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization, except: [:upload, :import]
  before_action :ensure_allows_file_imports, only: [:upload, :import]

  # Retrieves all assignments for a given provider course
  # GET /api/assignments/importers/:importer_provider_id/course/:id/assignments
  def index
    @provider_name = params[:importer_provider_id]
    @assignments = syllabus(@provider_name).assignments(params[:id])

    render "api/importers/grades/assignments", status: 200
  end

  # Takes the uploaded file and returns transformed json
  # POST /api/assignments/importers/:importer_provider_id/upload
  def upload
    provider = params[:importer_provider_id]

    render json: { message: "No file was present", success: false },
      status: 404 and return if params[:file].blank?

    render json: { message: "File format must be CSV", success: false },
      status: 404 and return if File.extname(params[:file].original_filename) != ".csv"

    @assignment_rows = CSVAssignmentImporter.new.as_assignment_rows(params[:file].tempfile)
    render "api/assignments/importers/upload", status: 200
  end

  # Creates the assignments from the imported data
  def import
    result = CSVAssignmentImporter.new.import assignment_import_params[:assignment_attributes],
      current_course

    render json: MultiJson.dump(result), status: 200
  end

  private

  def assignment_import_params
    params.require(:assignments).permit assignment_attributes: [
      :assignment_name, :assignment_type, :selected_assignment_type,
      :selected_open_date, :selected_due_date,
      :full_points, :description, :purpose, :required
    ]
  end

  # Ensure that the provided importer provider id allows uploads, downloads and
  # has a show template
  def ensure_allows_file_imports
    redirect_to({ action: :index },
      notice: "Invalid provider id") if !Assignments::ImportersController::ALLOWED_IMPORTER_IDS.include? \
        (params[:provider_id] || params[:importer_provider_id])
  end

  def syllabus(provider)
    @syllabus ||= ActiveLMS::Syllabus.new \
      provider,
      authorization(provider).access_token
  end
end
