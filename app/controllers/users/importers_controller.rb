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
end
