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
    @total_points = current_course.total_points
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
    gse = params[:grade_scheme_elements_attributes]
    ActiveRecord::Base.transaction do
      begin
        @course.grade_scheme_elements.where(id: params[:deleted_ids]).destroy_all
        @course.update_attributes(:grade_scheme_elements_attributes => gse) unless gse.nil?
      rescue
        raise 'HandleThis'
      end
    end
    respond_to do |format|
      if @course.save
        format.json { render json: current_course.grade_scheme_elements.select(
          :id,
          :level,
          :low_range,
          :letter,
          :high_range,
          :course_id
        ) }

      else
        format.json { render json: false, status: :internal_server_error }
      end
    end
  end

  def update
    respond_to do |format|
      format.json { render json: true }
    end
  end

  def student_predictor_data
    @grade_scheme_elements = current_course.grade_scheme_elements.select(:id, :low_range, :letter, :level)
    @total_points = current_course.total_points
  end

  def student_predictor_data
    @grade_scheme_elements = current_course.grade_scheme_elements.select(:id, :low_range, :letter, :level)
    @total_points = current_course.total_points
  end
end
