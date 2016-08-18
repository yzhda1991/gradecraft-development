# The Grade Scheme Elements define the point thresholds earned at which students
# earn course wide levels and grades
class GradeSchemeElementsController < ApplicationController
  before_filter :ensure_staff?

  def index
    @title = "Grade Scheme"
    @grade_scheme_elements = current_course
                             .grade_scheme_elements.order_by_highest_points
  end

  def edit
    @grade_scheme_element = current_course.grade_scheme_elements.find(params[:id])
  end

  def update
    @grade_scheme_element = current_course.grade_scheme_elements.find(params[:id])
    if @grade_scheme_element.update_attributes(params[:grade_scheme_element])
      redirect_to grade_scheme_elements_path,
        notice: "#{@grade_scheme_element.name} successfully updated"
    else
      render action: "edit"
    end
  end

  # Edit all the grade scheme items for a course
  def mass_edit
    @title = "Edit Grade Scheme"
    @course = current_course
    @total_points = current_course.total_points
    @grade_scheme_elements =  current_course
                              .grade_scheme_elements.order_by_highest_points.select(
                                :id,
                                :level,
                                :lowest_points,
                                :letter,
                                :highest_points,
                                :course_id)
  end

  def mass_update
    @course = current_course
    gse = params[:grade_scheme_elements_attributes]
    GradeSchemeElement.transaction do
      begin
        @course.grade_scheme_elements.where(id:
          params[:deleted_ids]).destroy_all
        @course.update_attributes(
          grade_scheme_elements_attributes: gse) unless gse.nil?
      rescue
        raise "HandleThis"
      end
    end
    respond_to do |format|
      if @course.save
        format.json do
          render json: current_course.grade_scheme_elements.select(
            :id,
            :level,
            :lowest_points,
            :letter,
            :highest_points,
            :course_id)
        end
      else
        format.json { render json: false, status: :internal_server_error }
      end
    end
  end
  
  def export_structure
    course = current_user.courses.find_by(id: params[:id])
    respond_to do |format|
      format.csv { send_data GradeSchemeExporter.new.export(course), filename: "#{ course.name } Grading Scheme - #{ Date.today }.csv" }
    end
  end
end
