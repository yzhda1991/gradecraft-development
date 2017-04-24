require "active_lms"

class Users::ImportersController < ApplicationController
  include OAuthProvider

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action except: :index do |controller|
    controller.redirect_path users_importers_path
  end
  before_action :require_authorization, except: :index

  # GET /users/importers/:importer_provider_id/course/:id
  def users
    @provider_name = params[:importer_provider_id]
    @course_id = params[:id]
  end

  def users_import
    @provider_name = params[:importer_provider_id]

    @result = Services::ImportsLMSUsers.import @provider_name,
      authorization(@provider_name).access_token, params[:id], params[:user_ids],
      current_course

    if @result.success?
      render :user_import_results
    else
      redirect_to users_importer_users(params[:importer_provider_id], params[:id]),
        alert: "Failed to import #{params[:importer_provider_id]} users"
    end
  end
end
