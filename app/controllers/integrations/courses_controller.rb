# rubocop:disable AndOr
class Integrations::CoursesController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :integration_id

  before_action :ensure_staff?
  before_action do |controller|
    controller.redirect_path(integration_courses_path(params[:integration_id]))
  end
  before_action :link_canvas_credentials, if: Proc.new { |c| c.params[:integration_id] == "canvas" }
  before_action :require_authorization
  before_action :use_current_course

  def create
    authorize! :update, @course

    provider_name = params[:integration_id]
    linked_course = LinkedCourse.find_or_initialize_by course_id: @course.id,
      provider: provider_name
    linked_course.provider_resource_id = params[:id]
    linked_course.last_linked_at = DateTime.now
    linked_course.save

    redirect_to integrations_path, notice: "The #{provider_name.capitalize} course has been linked to #{@course.name}"
  end

  def destroy
    authorize! :update, @course

    provider_name = params[:integration_id]

    LinkedCourse.where(provider: provider_name,
                       course_id: @course.id,
                       provider_resource_id: params[:id]).destroy_all

    redirect_to integrations_path, notice: "The #{provider_name.capitalize} course has been unlinked from #{@course.name}"
  end
end
