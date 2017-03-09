class API::CoursesController < ApplicationController
  before_action :ensure_staff?, except: [:timeline_events]

  # accessed by the dashboard
  # GET api/courses
  def index
    render json: current_user.courses.to_json(only: [:id, :name, :course_number, :year, :semester])
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
