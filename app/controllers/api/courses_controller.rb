class API::CoursesController < ApplicationController
  before_action :ensure_staff?, only: :course_creation

  # accessed by the dashboard
  # GET api/courses
  def index
    @courses = current_user.courses.map do |c|
      { name: c.formatted_long_name, id: c.id, search_string: c.searchable_name }
    end
    render json: MultiJson.dump(@courses)
  end

  # GET api/courses/:course_id/course_creation
  def course_creation
    @course_creation = CourseCreation.find_or_create_for_course(params[:course_id])
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
