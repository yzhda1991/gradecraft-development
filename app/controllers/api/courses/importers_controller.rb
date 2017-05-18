class API::Courses::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action :link_canvas_credentials, if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization

  # GET /api/courses/importers/:importer_provider_id/courses
  def index
    @provider_name = params[:importer_provider_id]
    @courses = syllabus(@provider_name).courses

    render "api/integrations/courses/index", status: 200
  end

  private

  def syllabus(provider)
    @syllabus ||= ActiveLMS::Syllabus.new \
      provider,
      authorization(provider).access_token
  end
end
