class API::StudentsController < ApplicationController
  before_action :ensure_staff?, except: [:analytics]

  # accessed by the dashboard
  # PUT api/students
  def index
    students = current_course.students.map do |u|
      { name: u.name, id: u.id }
    end
    render json: MultiJson.dump(students)
  end

  # GET api/students/:id/analytics
  def analytics
    redirect_to root_path unless (current_user_is_staff? || current_user.id.to_s == params[:student_id])
    @student = User.find(params[:student_id])
    @assignment_types = current_course.assignment_types
    @earned_badge_points = @student.earned_badges.sum(&:points)
    @course_potential_for_student = current_course.total_points + @earned_badge_points
  end
end


