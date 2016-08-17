# The notion of this class is that it can query all of the data necessary
# to perform our course analytics exports. We've added an additional
# ContextFilter class for export classes that need to refine this data further,
# so this should just be core mongo and ActiveRecord data that could be
# re-used in any course-related analytics export.
#
class CourseExportContext
  attr_reader :course

  # This this is an export context for courses we only need a course here.
  #
  def initialize(course:)
    @course = course
  end

  # Mongoid queries
  #
  # This returns all mongo events that exist for the course
  #
  def events
    @events ||= Analytics::Event.where course_id: course.id
  end

  # Parse out the events and return only the predictor ones. This could be
  # performed through a mongo query, but since the events will also be queried
  # for through #events, we can just filter them here in ruby
  #
  def predictor_events
    @predictor_events ||= events.collect do |event|
      event.event_type == "predictor"
    end
  end

  # Queries using our Analytics::Aggregate classes.
  #
  def user_pageviews
    @user_pageviews ||= CourseUserPageview.data(:all_time, nil,
      { course_id: course.id }, { page: "_all" }
    )[:results]
  end

  def user_predictor_pageviews
    @user_predictor_pageviews ||= CourseUserPagePageview.data(:all_time, nil,
      { course_id: course.id, page: /predictor/ }
    )[:results]
  end

  def user_logins
    @user_logins ||= CourseUserLogin.data(:all_time, nil,
      { course_id: course.id }
    )[:results]
  end

  # ActiveRecord queries
  #
  def users
    return @users if @users
    user_ids = events.collect(&:user_id).compact.uniq
    @users = User.where(id: user_ids).select :id, :username
  end

  def assignments
    return @assignments if @assignments

    # get the ids of all assignments in the course that have an event
    assignment_ids = events.collect do |event|
      event.assignment_id if event.respond_to? :assignment_id
    end.compact.uniq

    @assignments = Assignment.where(id: assignment_ids).select :id, :name
  end
end
