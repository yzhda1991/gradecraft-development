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
    @users = syllabus.users(params[:id], false, importer_params.to_h)
    render template: "api/users/importers/index"
  end

  private

  # Permissible params to include in the request
  def importer_params
    params.permit(:enrollment_type, :user_ids)
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end
end
