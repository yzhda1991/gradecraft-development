class API::CoursesController < ApplicationController
  before_action :use_current_course, only: :analytics

  # accessed by the dashboard
  # GET api/courses
  def index
    @courses = current_user.courses.map do |c|
      { name: c.formatted_long_name, id: c.id, search_string: c.searchable_name }
    end
    render json: MultiJson.dump(@courses)
  end

  def analytics
    @scores =
      CourseMembership.where(course: @course, role: "student", auditing: false).pluck(:score).sort
    if current_user_is_student?
      @student = current_user
      @user_score = @student.course_memberships.where(course_id: @course, auditing: false).pluck("score").first
    else
      @student = nil
    end
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
