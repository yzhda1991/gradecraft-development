class API::AssignmentTypesController < ApplicationController

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
        :max_points,
        :description,
        :student_weightable,
        :position,
        :updated_at
      )
  end
end
