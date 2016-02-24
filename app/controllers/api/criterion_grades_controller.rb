require_relative "../../services/creates_grade_using_rubric"
require_relative "../../services/creates_group_grades_using_rubric"

class API::CriterionGradesController < ApplicationController
  before_filter :ensure_staff?

  # GET api/assignments/:id/student/:student_id/criterion_grades
  def index
    @criterion_grades = CriterionGrade.where(
      student_id: params[:student_id],
      assignment_id: params[:id]
    ).select(
      :id, :student_id, :criterion_id, :level_id, :comments
    )
  end

  def group_index
    if !Assignment.find(params[:id]).has_groups?
      render json: { errors: [{ detail: "not a group assignment" }], success: false }, status: 400
    else
      @student_ids = Group.find(params[:group_id]).students.pluck(:id)
      @criterion_grades = CriterionGrade.where(
        student_id: @student_ids, assignment_id: params[:id]
      ).select(
        :id, :student_id, :criterion_id, :level_id, :comments
      )
    end
  end

  # PUT api/assignments/:assignment_id/students/:student_id/criterion_grade
  def update
    result = Services::CreatesGradeUsingRubric.create params
    if result.success?
      render json: { message: "Grade successfully saved", success: true }, status: 200
    else
      render json: { errors: [{ detail: result.message }], success: false }, status:  result.error_code || 400
    end
  end

  # PUT api/assignments/:assignment_id/groups/:group_id/criterion_grade
  def group_update
    result = Services::CreatesGroupGradesUsingRubric.create params
    if result.success?
      render json: { message: "Grade successfully saved", success: true }, status: 200
    else
      render json: { errors: [{ detail: result.message }], success: false }, status:  result.error_code || 400
    end
  end
end


