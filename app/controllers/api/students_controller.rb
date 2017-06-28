class API::StudentsController < ApplicationController
  before_action :ensure_staff?, except: [:analytics, :week_analytics]
  before_action :ensure_student?, only: [:analytics, :week_analytics]

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
    analytics_params current_user
  end

  # accessed by faculty on the student show page
  # GET api/students/:id/analytics
  def student_analytics
    analytics_params User.find(params[:id])
    render "api/students/analytics"
  end

  # GET api/students/week_analytics
  def week_analytics

  end

  # GET api/students/:id/week_analytics
  def student_week_analytics
    render "api/students/week_analytics"
  end

  private

  def analytics_params(student)
    @student = student
    @assignment_types = current_course.assignment_types
    @earned_badge_points = @student.earned_badge_score_for_course current_course
    @course_potential_points_for_student = current_course.total_points + @earned_badge_points
  end
end


