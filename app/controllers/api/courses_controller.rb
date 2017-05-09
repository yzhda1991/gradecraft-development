class API::CoursesController < ApplicationController

  # accessed by the dashboard
  # GET api/courses
  def index
    @courses = current_user.courses.map do |c|
      { name: c.formatted_long_name, id: c.id, search_string: c.searchable_name }
    end
    render json: MultiJson.dump(@courses)
  end

  # accessed by the dashboard
  # GET api/timeline_events
  def timeline_events
    @events = Timeline.new(current_course).events_by_due_date
  end
end
