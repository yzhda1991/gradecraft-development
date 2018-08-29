# The Grade Scheme Elements define the point thresholds earned at which students
# earn course wide levels and grades
class GradeSchemeElementsController < ApplicationController
  before_action :ensure_staff?, except: :index
  before_action :use_current_course, only: :mass_edit

  def index
    @grade_scheme_elements = current_course.grade_scheme_elements.order_by_points_desc
  end

  def edit
    @grade_scheme_element = current_course.grade_scheme_elements.find(params[:id])
  end

  def update
    @grade_scheme_element = current_course.grade_scheme_elements.find(params[:id])
    if @grade_scheme_element.update_attributes(grade_scheme_element_params)
      redirect_to grade_scheme_elements_path,
        notice: "#{@grade_scheme_element.name} successfully updated"
    else
      render action: "edit"
    end
  end

  # Edit all the grade scheme items for a course
  def mass_edit
  end

  def export_structure
    course = current_user.courses.find_by(id: params[:id])
    respond_to do |format|
      format.csv { send_data GradeSchemeExporter.new.export(course), filename: "#{ course.name } Grading Scheme - #{ Date.today }.csv" }
    end
  end

  private

  def grade_scheme_element_params
    params.require(:grade_scheme_element).permit :id, :letter, :lowest_points,
      :level, :description, :course_id, unlock_conditions_attributes: [:id, :unlockable_id, :unlockable_type, :condition_id, :condition_type, :condition_state, :condition_value, :condition_date, :_destroy]
  end
end
