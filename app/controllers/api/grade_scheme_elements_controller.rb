# The Grade Scheme Elements define the point thresholds earned at which students
# earn course wide levels and grades
class API::GradeSchemeElementsController < ApplicationController
  ALLOWED_GSE_ATTRIBUTES = %i{id letter lowest_points level description course_id}.freeze
  private_constant :ALLOWED_GSE_ATTRIBUTES

  before_action :ensure_staff?, except: :index
  before_action :find_grade_scheme_element, only: [:update, :destroy]
  before_action :use_current_course, only: :mass_update

  # GET /api/grade_scheme_elements
  def index
    assign_for_index
    @student = current_student if current_user_is_student?
  end

  # POST /api/grade_scheme_elements
  def create
    @grade_scheme_element = current_course.grade_scheme_elements.new grade_scheme_element_params

    if @grade_scheme_element.save
      render "api/grade_scheme_elements/show", status: 201
    else
      render json: { message: "Failed to create grade scheme element", success: false },
        status: :internal_server_error
    end
  end

  # PUT /api/grade_scheme_elements/:id
  def update
    if @grade_scheme_element.update grade_scheme_element_params
      render "api/grade_scheme_elements/show", status: 200
    else
      render json: { message: "Failed to update grade scheme element", success: false },
        status: :internal_server_error
    end
  end

  # POST /api/grade_scheme_elements/mass_update
  def mass_update
    if @course.update! mass_grade_scheme_elements_params
      @course.recalculate_student_scores
      assign_for_index
      render "api/grade_scheme_elements/index", status: 200
    else
      render json: { message: "Failed to update grade scheme elements", success: false },
        status: :internal_server_error
    end
  end

  # DELETE /api/grade_scheme_elements/:id
  def destroy
    @grade_scheme_element.destroy

    if @grade_scheme_element.destroyed?
      render json: { message: "Successfully deleted #{@grade_scheme_element.name}", success: true },
        status: 200
    else
      render json: { message: "Failed to delete #{@grade_scheme_element.name}", success: false },
        status: 500
    end
  end

  # DELETE /api/grade_scheme_elements/destroy_all
  def destroy_all
    current_course.grade_scheme_elements.destroy_all

    if current_course.grade_scheme_elements.any?
      render json: { message: "Failed to delete grade scheme elements", success: false },
        status: :internal_server_error
    else
      render json: { message: "Grade scheme elements successfully deleted", success: true },
        status: :ok
    end
  end

  private

  def grade_scheme_element_params
    params.require(:grade_scheme_element).permit ALLOWED_GSE_ATTRIBUTES
  end

  def mass_grade_scheme_elements_params
    params.permit grade_scheme_elements_attributes: ALLOWED_GSE_ATTRIBUTES
  end

  def find_grade_scheme_element
    @grade_scheme_element = current_course.grade_scheme_elements.find params[:id]
  end

  def assign_for_index
    @grade_scheme_elements = current_course
      .grade_scheme_elements
      .ordered
      .select(:id, :lowest_points, :letter, :level)

    if @grade_scheme_elements.any?
      @total_points = (@grade_scheme_elements.first.lowest_points).to_i
    else
      @total_points = current_course.total_points
    end
  end
end
