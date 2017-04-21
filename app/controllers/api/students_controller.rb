class API::StudentsController < ApplicationController
  before_action :ensure_staff?, except: [:analytics]
  before_action :ensure_student?, only: [:analytics]

  # accessed by the dashboard
  # PUT api/students
  def index
    students = current_course.students.map do |u|
      { name: u.name, id: u.id }
    end
    render json: MultiJson.dump(students)
  end

  # accessed on the student dashboard
  # GET api/students/analytics
  def analytics
    @student = current_user
    @assignment_types = current_course.assignment_types
    @earned_badge_points = @student.earned_badges.sum(&:points)
    @course_potential_points_for_student = current_course.total_points + @earned_badge_points
  end
end


