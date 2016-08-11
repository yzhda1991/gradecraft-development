# for now let's just move all of the data that we need to fetch to generate the
# course analytics export files into a single context so that they're just kind
# of contained here and we don't have to deal with them any further for now.
#
# We need to break these out into more organized sub-categories so we can at
# least keep the mongoid records, the active_record records, and the analytics
# aggregates data together in each respective grouping.
#
# For now, though, we've got it all here so it's at least segregated from the
# rest of the course analytics export process.
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
  def events
    @events ||= Analytics::Event.where course_id: course.id
  end

  # This one can probably just be performed by filtering through the events
  # records with a ruby select method without having to hit the database again
  # since #events is just grabbing all of our Analytics events for the course
  # anwyay.
  #
  def predictor_events
    @predictor_events ||= Analytics::Event.where \
      course_id: course.id,
      event_type: "predictor"
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
    @users ||= User.where(id: user_ids).select :id, :username
  end

  def assignments
    @assignments ||= Assignment.where(id: assignment_ids).select :id, :name
  end

  # Parsed user and assignment data from ActiveRecord queries
  #
  # { user_id => "some_username" }
  def usernames
    @usernames ||= users.inject({}) do |memo, user|
      memo[user.id] = user.username
      memo
    end
  end

  # { assignment_id => "some_assignment_name" }
  #
  def assignment_names
    @assignment_names ||= assignments.inject({}) do |hash, assignment|
      hash[assignment.id] = assignment.name
      hash
    end
  end

  def user_ids
    @user_ids ||= events.collect(&:user_id).compact.uniq
  end

  def assignment_ids
    @assignment_ids ||= events.inject([]) do |memo, event|
      memo << event.assignment_id if event.respond_to? :assignment_id
      memo
    end.compact.uniq
  end
end
