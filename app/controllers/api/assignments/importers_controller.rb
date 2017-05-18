class API::Assignments::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action :link_canvas_credentials, if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization

  # Retrieves all assignments for a given provider course
  # GET /api/assignments/importers/:importer_provider_id/course/:id/assignments
  def index
    @provider_name = params[:importer_provider_id]
    @assignments = syllabus(@provider_name).assignments(params[:id])

    render "api/importers/grades/assignments", status: 200
  end

  def syllabus(provider)
    @syllabus ||= ActiveLMS::Syllabus.new \
      provider,
      authorization(provider).access_token
  end
end
