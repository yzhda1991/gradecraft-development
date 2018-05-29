# rubocop:disable AndOr
class API::Courses::StudentsController < ApplicationController
  before_action :ensure_staff?
  before_action :find_course

  # GET api/courses/:course_id/students
  # Batchable
  def index
    @students = User.students_for_course @course

    render json: { student_ids: @students.pluck(:id) }, status: :ok \
      and return if params[:fetch_ids] == "1"

    @students = @students.where(id: params[:student_ids]) if params[:student_ids].present?
    @teams = @course.teams if @course.has_teams?
    @earned_badges = @course.earned_badges.where student_id: @students.pluck(:id)
    @flagged_users = FlaggedUser.for_course(@course).for_flagger current_user
  end

  private

  def find_course
    @course = Course.includes(:teams, :earned_badges).find params[:course_id]
  end
end
