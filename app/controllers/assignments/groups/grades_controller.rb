require_relative "../../../services/creates_many_group_grades"

class Assignments::Groups::GradesController < ApplicationController
  before_action :ensure_staff?
  before_action :find_assignment
  before_action :use_current_course

  # GET /assignments/:assignment_id/groups/grades/mass_edit
  def mass_edit
  end

  # PUT /assignments/:assignment_id/groups/grades/mass_update
  def mass_update
    filter_params_with_no_grades!
    params[:assignment][:grades_by_group] = assignment_group_grades_params[:grades_by_group].each do |key, value|
      value.merge!(instructor_modified: true, complete: true, student_visible: true)
    end

    result = Services::CreatesManyGroupGrades.call @assignment.id,
      current_user.id,
      assignment_group_grades_params

    if result.success?
      respond_with @assignment
    else
      redirect_to mass_edit_assignment_groups_grades_path(@assignment),
        notice: "Oops! There was an error while saving the grades!"
    end
  end
end

private

def assignment_group_grades_params
  params.require(:assignment).permit grades_by_group: [:graded_by_id, :graded_at,
    :instructor_modified, :raw_points, :pass_fail_status, :group_id, :complete, :student_visible]
end

def find_assignment
  @assignment = current_course.assignments.find(params[:assignment_id])
end

def filter_params_with_no_grades!
  params[:assignment][:grades_by_group].delete_if do |key, value|
    value[:raw_points].blank? && (value[:pass_fail_status].blank? || value[:pass_fail_status] == "nil")
  end
end
