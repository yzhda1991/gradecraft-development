class GradeSchemeElementsController < ApplicationController

  #The Grade Scheme Elements define the point thresholds earned at which students earn course wide levels and grades

  before_filter :ensure_staff?, :except => [:student_predictor_data]

  def index
    @title = "Grade Scheme"
    @grade_scheme_elements = current_course.grade_scheme_elements
  end

  # Edit all the grade scheme items for a course
  def mass_edit
    @title = "Edit Grade Scheme"
    @course = current_course
    @grade_scheme_elements = current_course.grade_scheme_elements.select(
      :id,
      :level,
      :low_range,
      :letter,
      :high_range,
      :course_id
    )
  end

  def mass_update
    @course = current_course
    @course.update_attributes(:grade_scheme_elements_attributes => params[:grade_scheme_elements_attributes])
    respond_to do |format|
      if @course.save
        format.json { render json: true }
      else
        format.json { render json: false }
      end
    end
    # @course = current_course
    # @course.update_attributes(params[:course])
    # respond_to do |format|
    #   if @course.save
    #     format.html { redirect_to grade_scheme_elements_path }
    #   else
    #     @title = "Edit Grade Scheme"
    #     @grade_scheme_elements = current_course.grade_scheme_elements
    #     format.html { render action: "mass_edit" }
    #   end
    # end
  end

  def update
    respond_to do |format|
      format.json { render json: true }
    end
    # @grade_scheme_element = params[:grade_scheme_element]
    # @grade_scheme_element.update_attributes params[:grade_scheme_element]
    # respond_with @rubric, status: :not_found
  end

  def student_predictor_data
    @grade_scheme_elements = current_course.grade_scheme_elements.select(:id, :low_range, :letter, :level)
    @total_points = current_course.total_points
  end
end
