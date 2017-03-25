# The Grade Scheme Elements define the point thresholds earned at which students
# earn course wide levels and grades
class API::GradeSchemeElementsController < ApplicationController
  before_action :ensure_staff?, except: :index

  # GET /api/grade_scheme_elements
  def index
    @grade_scheme_elements = current_course
                             .grade_scheme_elements
                             .order_by_points_desc.select(
                               :id,
                               :lowest_points,
                               :letter,
                               :level)
    if @grade_scheme_elements.present?
      @total_points = (@grade_scheme_elements.first.lowest_points).to_i
    else
      @total_points = current_course.total_points
    end
  end

  # DELETE /api/grade_scheme_elements
  def destroy
    current_course.grade_scheme_elements.destroy_all
    if current_course.grade_scheme_elements.any?
      render json: { message: "Failed to delete grade scheme elements", success: false },
        status: 500
    else
      render json: { message: "Grade scheme elements successfully deleted", success: true },
        status: 200
    end
  end
end
