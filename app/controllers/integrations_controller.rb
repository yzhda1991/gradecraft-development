class IntegrationsController < ApplicationController
  include OAuthProvider

  oauth_provider_param :integration_id

  before_filter :ensure_staff?, :require_authorization

  def index
    @course = current_course
    authorize! :read, @course
  end

  def create
    redirect_to integration_courses_path(params[:integration_id])
  end
end
