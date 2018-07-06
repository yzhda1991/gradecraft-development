require_relative "../../services/creates_grade_using_rubric"

class API::CriterionGradesController < ApplicationController
  before_action :ensure_staff?

  # GET api/assignments/:assignment_id/students/:student_id/criterion_grades
  def index
    @criterion_grades = CriterionGrade.where(
      assignment_id: params[:assignment_id],
      student_id: params[:student_id]
    ).select(
      :id, :student_id, :criterion_id, :level_id, :comments
    )
  end

  # GET api/assignments/:assignment_id/groups/:group_id/criterion_grades
  def group_index
    if !Assignment.find(params[:assignment_id]).has_groups?
      render json: {
        errors: [{ detail: "not a group assignment" }], success: false
        },
        status: 400
    else
      @student_ids = Group.find(params[:group_id]).students.pluck(:id)
      @criterion_grades = CriterionGrade.where(
        student_id: @student_ids, assignment_id: params[:assignment_id]
      ).select(
        :id, :student_id, :criterion_id, :level_id, :comments
      )
    end
  end

  # PUT api/assignments/:assignment_id/students/:student_id/criterion_grades
  def update
    result = Services::CreatesGradeUsingRubric.call params, current_user.id
    if result.success?
      @grade = result.grade.reload
      render "api/grades/show", success: true, status: 200
    else
      render json: {
        errors: [{ detail: result.message }], success: false
        },
        status:  result.error_code || 400
    end
  end

  # PUT api/assignments/:assignment_id/students/:student_id/criteria/:id/update_fields
  def update_fields
    @criterion_grade = CriterionGrade.find_or_create(params[:assignment_id], params[:id], params[:student_id])
    grade_id = Grade.where(assignment_id: params[:assignment_id], student_id:  params[:student_id]).first.id
    result = @criterion_grade.update_attributes(criterion_grade_params(grade_id))
    if result
      # We will need to run GradeUpdaterJob.new(grade_id: @criterion_grade.grade_id)
      # or similar if we want to update every time points change.
      # Currently, this is handled only from the submit button.
      render "api/criterion_grades/show", success: true,
      status: 200
    else
      render json: {
        errors: result.errors, success: false
      }, status: 400
    end
  end

  # PUT api/assignments/:assignment_id/groups/:group_id/criteria/:id/update_fields
  def group_update_fields
    group = Group.find(params[:group_id])
    results = []
    @criterion_grades = []
    group.students.each do |student|
      grade_id = Grade.where(assignment_id: params[:assignment_id], student_id: student.id).first.id
      cg = CriterionGrade.find_or_create(params[:assignment_id], params[:id], student.id)
      results << cg.update_attributes(criterion_grade_params(grade_id))
      @criterion_grades << cg
    end
    if results.all?
      render "api/criterion_grades/index", success: true,
      status: 200
    else
      render json: {
        errors: results, success: false
      }, status: 400
    end
  end

  private

  def criterion_grade_params(grade_id)
    params.require(:criterion_grade).permit(:comments, :level_id, :points).merge(grade_id: grade_id)
  end
end
