class API::CoursesController < ApplicationController

  # accessed by the dashboard
  # GET api/courses
  def index
    @courses = []
    current_user.courses.each do |course|
      @courses << course.create_searchable_course
    end
    return @courses
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
