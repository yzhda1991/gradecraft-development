require_relative "../../../services/creates_many_group_grades"

class Assignments::Groups::GradesController < ApplicationController
  before_filter :ensure_staff?
  before_action :find_assignment

  # GET /assignments/:assignment_id/groups/grades/mass_edit
  def mass_edit
    presenter = Assignments::Grades::MassEditPresenter.build({
      assignment: @assignment
    })
    render :mass_edit, presenter
  end

  # PUT /assignments/:assignment_id/groups/grades/mass_update
  def mass_update
    filter_params_with_no_grades! :grades_by_group
    result = Services::CreatesManyGroupGrades.create @assignment.id, current_user.id, assignment_group_grades_params

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
                                                         :instructor_modified, :raw_points,
                                                         :status, :pass_fail_status, :group_id]
end

def find_assignment
  @assignment = current_course.assignments.find(params[:assignment_id])
end

def filter_params_with_no_grades!(attribute_name)
  params[:assignment][attribute_name] = params[:assignment][attribute_name].delete_if do |key, value|
    value[:raw_points].nil? || value[:raw_points].empty?
  end
end
