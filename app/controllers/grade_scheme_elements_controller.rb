class GradeSchemeElementsController < ApplicationController

  #The Grade Scheme Elements define the point thresholds earned at which students earn course wide levels and grades

  before_filter :ensure_staff?, :except => [:predictor_data]

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
    GradeSchemeElement.transaction do
      begin
        @course.grade_scheme_elements.where(id: params[:deleted_ids]).destroy_all
        @course.update_attributes(:grade_scheme_elements_attributes => gse) unless gse.nil?
      rescue
        raise "HandleThis"
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

  # TODO: Here we set the total earnable points as 110% of the low range of the higest earnable grade,
  # and we default to a (most likely nil value) course.total_points if the professor has not yet created the
  # grade scheme elements.
  # We need:
  # 1. A workflow that allows professors to create a course in a natural progression,
  #    but does not allow for a course without grade scheme elements
  # 2. A way to calculate the total points on the course, if it is not set.
  # 3. Update spec to include all valid scenarios
  def predictor_data
    @grade_scheme_elements = current_course.grade_scheme_elements.select(:id, :low_range, :letter, :level)
    if @grade_scheme_elements.present?
      @total_points = (@grade_scheme_elements.first.low_range * 1.1).to_i
    else
      @total_points = current_course.total_points
    end
  end
end
