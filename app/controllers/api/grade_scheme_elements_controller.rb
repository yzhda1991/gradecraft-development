# The Grade Scheme Elements define the point thresholds earned at which students
# earn course wide levels and grades
class API::GradeSchemeElementsController < ApplicationController
  before_action :ensure_staff?, except: :index
  before_action :use_current_course, only: :update

  # GET /api/grade_scheme_elements
  def index
    assign_for_index
    @student = current_student if current_user_is_student?
  end

  # POST /api/grade_scheme_elements
  def update
    begin
      GradeSchemeElement.transaction do
        @course.grade_scheme_elements.where(id: params[:deleted_ids]).destroy_all
        @course.update! grade_scheme_elements_params
      end

      @course.students.pluck(:id).each do |id|
        ScoreRecalculatorJob.new(user_id: id, course_id: @course.id).enqueue
      end

      assign_for_index
      render "api/grade_scheme_elements/index", status: 200
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      render json: { message: "Failed to update grade scheme elements", success: false },
        status: :internal_server_error
    end
  end

  # DELETE /api/grade_scheme_elements
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

  def grade_scheme_elements_params
    params.permit grade_scheme_elements_attributes: [:id, :letter, :lowest_points,
      :level, :description, :course_id]
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
