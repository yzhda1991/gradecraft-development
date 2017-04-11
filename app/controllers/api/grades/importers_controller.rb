class API::Grades::ImportersController < ApplicationController
  include OAuthProvider

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action :require_authorization

  # GET /api/assignments/:assignment_id/grades/importers/:importer_provider_id/course/:id
  def show
    @assignment = Assignment.find params[:assignment_id]
    @provider_name = params[:importer_provider_id]
    @grades = syllabus.grades(params[:id], [params[:assignment_ids]].flatten, nil, false, importer_params.to_h)
    @provider_assignment = syllabus.assignment(params[:id], params[:assignment_ids])
    render template: "api/grades/importers/show"
  end

  private

  def importer_params
    params.permit(:page, :per_page)
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end
end
