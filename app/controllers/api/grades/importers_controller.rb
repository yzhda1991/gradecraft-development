# rubocop:disable AndOr
class API::Grades::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action :link_canvas_credentials, if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization

  # GET /api/assignments/:assignment_id/grades/importers/:importer_provider_id/course/:id
  def show
    @assignment = Assignment.find params[:assignment_id]
    @provider_name = params[:importer_provider_id]
    @result = syllabus.grades(params[:id], [params[:assignment_ids]].flatten, nil, false, importer_params.to_h) do
      render json: { message: "There was an issue trying to retrieve the grades from #{@provider_name.capitalize}.",
        success: false }, status: 500 and return
    end
    @provider_assignment = syllabus.assignment(params[:id], params[:assignment_ids]) do
      render json: { message: "There was an issue trying to retrieve the assignment from #{@provider_name.capitalize}.",
        success: false }, status: 500 and return
    end
    render template: "api/grades/importers/show"
  end

  private

  def importer_params
    params.permit :page
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end
end
