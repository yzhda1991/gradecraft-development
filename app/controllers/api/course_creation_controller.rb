class API::CourseCreationController < ApplicationController
  before_action :ensure_staff?

  # GET api/course_creation
  def show
    @course_creation = CourseCreation.find_or_create_for_course(current_course.id)
  end


  # PUT api/course_creation
  def update
    @course_creation = CourseCreation.find_or_create_for_course(current_course.id)

    if @course_creation.update_attributes(course_creation_params)
      render "api/course_creation/show", status: 200
    else
      render json: {
        errors: [{ detail: "failed to update course creation" }], success: false
        },
        status: 500
    end
  end

  private

  def course_creation_params
    params.require(:course_creation).permit(
      :settings_done, :attendance_done, :assignments_done, :calendar_done,
      :instructors_done, :roster_done, :badges_done, :teams_done)
  end
end
