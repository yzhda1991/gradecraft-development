class API::CoursesController < ApplicationController
  before_action :ensure_staff?, except: [:timeline_events]

  # accessed by the dashboard
  # GET api/courses
  def index
    @courses = current_user.courses.select(:id, :name, :course_number, :year, :semester)
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
