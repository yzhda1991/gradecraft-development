class API::GradesController < ApplicationController

  before_filter :ensure_staff?

  # GET api/assignments/:id/students/:student_id/grade
  def show
    @grade = Grade.find_or_create(params[:id], params[:student_id])
    @grade_status_options = @grade.assignment.release_necessary? ?
      ["In Progress", "Graded", "Released"] : ["In Progress", "Graded"]
  end

  # GET api/assignments/:id/groups/:group_id/grades
  def group_index
    assignment = Assignment.find(params[:id])
    if !assignment.has_groups?
      render json: { message: "not a group assignment", success: false }, status: 400
    else
      students = Group.find(params[:group_id]).students
      @student_ids = students.pluck(:id)
      #TODO: Change this method globally to accept student ids
      @grades = Grade.find_or_create_grades(params[:id], students)
      @grade_status_options = assignment.release_necessary? ?
        ["In Progress", "Graded", "Released"] : ["In Progress", "Graded"]
    end
  end
end


