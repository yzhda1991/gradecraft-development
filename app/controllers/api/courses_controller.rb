class API::CoursesController < ApplicationController
  before_action :ensure_staff?, only: :show
  before_action :use_current_course, only: [:analytics, :one_week_analytics]

  # GET api/courses
  def index
    if current_user_is_admin?
      @courses = Course.includes(:earned_badges, course_memberships: :user).all
    else
      @courses = current_user.courses
    end
    render :"api/courses/index", status: :ok
  end

  # GET /api/courses/:id
  def show
    @course = Course.includes(:grade_scheme_elements).find params[:id]
  end

  # GET api/courses/analytics
  def analytics
    if current_user_is_student?
      @student = current_user
      @user_score = @student.course_memberships.where(course_id: @course, auditing: false).pluck("score").first
    end
  end

  # GET api/courses/one_week_analytics
  def one_week_analytics
    if current_user_is_student?
      @student = current_user
    else
      @student = User.find(params[:student_id]) if params[:student_id]
    end
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
