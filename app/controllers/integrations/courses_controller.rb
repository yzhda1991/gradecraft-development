class Integrations::CoursesController < ApplicationController
  include OAuthProvider

  oauth_provider_param :integration_id

  before_filter :ensure_staff?
  before_filter do |controller|
    controller.redirect_path(integration_courses_path(params[:integration_id]))
  end
  before_filter :require_authorization

  def index
    @course = current_course
    authorize! :read, @course

    @provider_name = params[:integration_id]
    @courses = syllabus(@provider_name).courses
  end

  def create
    course = current_course
    authorize! :read, course

    provider_name = params[:integration_id]
    LinkedCourse.create course_id: course.id, provider_resource_id: params[:id],
      provider: provider_name, last_linked_at: DateTime.now

    redirect_to integrations_path(provider_name)
  end

  private

  def syllabus(provider)
    @syllabus ||= ActiveLMS::Syllabus.new \
      provider,
      authorization(provider).access_token
  end
end
