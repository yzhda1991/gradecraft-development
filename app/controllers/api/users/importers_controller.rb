# rubocop:disable AndOr
class API::Users::ImportersController < ApplicationController
  include OAuthProvider

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action only: :show do |controller|
    controller.redirect_path \
      users_importer_users_path(params[:importer_provider_id], params[:id])
  end
  before_action :require_authorization

  # GET /api/users/importers/:importer_provider_id/course/:id/users
  def index
    @provider_name = params[:importer_provider_id]
    @result = syllabus.users(params[:id], false, importer_params.to_h) do
      render json: { message: "There was an issue trying to retrieve the course from #{@provider_name.capitalize}.",
        success: false }, status: 500 and return
    end
    render template: "api/users/importers/index"
  end

  private

  # Permissible params to include in the request
  def importer_params
    params.permit :page
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end
end
