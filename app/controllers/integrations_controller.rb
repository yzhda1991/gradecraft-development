class IntegrationsController < ApplicationController
  include OAuthProvider

  oauth_provider_param :integration_id

  before_filter :ensure_staff?
  before_filter except: :index do |controller|
    controller.redirect_path(courses_integration_path(params[:integration_id]))
  end
  before_filter :require_authorization, except: :index

  def index
    @course = current_course
    authorize! :read, @course
  end

  def create
    redirect_to courses_integration_path(params[:integration_id])
  end

  def courses
    @course = current_course
    authorize! :read, @course

    @provider_name = params[:integration_id]
    @courses = syllabus(@provider_name).courses
  end

  private

  def syllabus(provider)
    @syllabus ||= ActiveLMS::Syllabus.new \
      provider,
      authorization(provider).access_token
  end
end
