# rubocop:disable AndOr
class API::Assignments::StudentsController < ApplicationController
  before_action :ensure_staff?
  before_action :find_assignment

  # GET /api/assignments/:assignment_id/students
  def index
    team = current_course.teams.find(params[:team_id]) unless params[:team_id].blank?

    @students = current_course
      .students
      .active_students_for_course(current_course, team)
      .order_by_name

    render json: { student_ids: @students.pluck(:id) }, status: :ok \
      and return if params[:fetch_ids] == "1"

    @students = @students.where(id: params[:student_ids]) if params[:student_ids].present?
  end

  private

  def find_assignment
    @assignment = current_course.assignments.find params[:assignment_id]
  end
end
