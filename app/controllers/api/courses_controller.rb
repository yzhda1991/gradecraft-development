class API::CoursesController < ApplicationController
  before_action :ensure_staff?

  # PUT api/courses
  def index
    render json: current_user.courses.to_json(only: [:id, :name, :course_number, :year, :semester])
  end
end
