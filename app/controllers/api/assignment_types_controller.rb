class API::AssignmentTypesController < ApplicationController
  include SortsPosition

  before_action :ensure_staff?, only: [:sort]

  # GET api/assignment_types
  def index
    if current_user_is_student?
      @student = current_student
      @update_weights = true
    else
      @update_weights = false
    end
    @assignment_types =
      current_course.assignment_types.ordered.select(
        :course_id,
        :id,
        :name,
        :has_max_points,
        :max_points,
        :description,
        :student_weightable,
        :position,
        :top_grades_counted,
        :updated_at
      )
  end

  # GET api/assignment_types/:id
  def show
    begin
      @assignment_type = AssignmentType.find params[:id]
    rescue ActiveRecord::RecordNotFound
      render json: { message: "Assignment type not found", success: false }, status: :not_found
    end
  end

  def sort
    sort_position_for "assignment-type"
  end
end
