class IntegrationsController < ApplicationController
  include OAuthProvider

  oauth_provider_param :integration_id

  before_action :ensure_staff?
  before_action except: :index do |controller|
    controller.redirect_path(integration_courses_path(params[:integration_id]))
  end
  before_action :require_authorization, except: :index

  def index
    @course = current_course
    authorize! :read, @course
  end

  def create
    redirect_to integration_courses_path(params[:integration_id])
  end
end
