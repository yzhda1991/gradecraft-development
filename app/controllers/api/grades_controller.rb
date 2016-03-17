class API::GradesController < ApplicationController

  before_filter :ensure_staff?

  # GET api/assignments/:assignment_id/students/:student_id/grade
  def show
    @grade = Grade.find_or_create(params[:assignment_id], params[:student_id])
    @grade_status_options = @grade.assignment.release_necessary? ?
      Grade::STATUSES : Grade::UNRELEASED_STATUSES
  end

  # GET api/assignments/:assignment_id/groups/:group_id/grades
  def group_index
    assignment = Assignment.find(params[:assignment_id])
    if !assignment.has_groups?
      render json: {
        message: "not a group assignment", success: false
        },
        status: 400
    else
      students = Group.find(params[:group_id]).students
      @student_ids = students.pluck(:id)
      @grades =
        Grade.find_or_create_grades(params[:assignment_id], @student_ids)
      @grade_status_options = assignment.release_necessary? ?
        Grade::STATUSES : Grade::UNRELEASED_STATUSES
    end
  end
end


