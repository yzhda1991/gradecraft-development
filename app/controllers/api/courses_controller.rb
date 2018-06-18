# rubocop:disable AndOr
class API::CoursesController < ApplicationController
  before_action :ensure_staff?, only: :show
  before_action :use_current_course, only: [:analytics, :one_week_analytics]

  # GET api/search
  # Used specifically for typeahead on course search input
  def search
    course_attrs = current_user.courses.map do |c|
      {
        id: c.id,
        formatted_name: c.formatted_long_name,
        search_string: c.searchable_name
      }
    end
    render json: MultiJson.dump(course_attrs)
  end

  # GET api/courses
  def index
    @courses = current_user_is_admin? ? Course.all : current_user.courses

    if current_user_is_admin?
      render json: MultiJson.dump(course_ids: @courses.pluck(:id)), status: :ok \
        and return if params[:fetch_ids] == "1"

      @courses = @courses.where(id: params[:course_ids]) if params[:course_ids].present?
    end
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
