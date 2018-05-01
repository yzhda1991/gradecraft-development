class API::Courses::StudentsController < ApplicationController
  before_action :ensure_staff?
  before_action :find_course

  # GET api/courses/:course_id/students
  def index
    @teams = @course.teams if @course.has_teams?
    @students = User.students_for_course(@course, params[:team_id]).order_by_high_score @course.id
    @earned_badges = @course.earned_badges.where student_id: @students.pluck(:id)
    @flagged_users = FlaggedUser.for_course(@course).for_flagger current_user
  end

  private

  def find_course
    @course = Course.includes(:teams, :earned_badges).find params[:course_id]
  end
end
