class IntegrationsController < ApplicationController
  include OAuthProvider

  before_filter :ensure_staff?, :require_authorization

  def index
    @course = current_course
    authorize! :read, @course
  end

  def create
    redirect_to integration_courses_path(params[:importer_provider_id])
  end
end
