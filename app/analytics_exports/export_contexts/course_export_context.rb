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

  # this is the data hash that we're going to pass into the export classes
  # so they can figure out what they ultimately need to present.
  #
  # In the adjacent 2132 branch we've started moving this more toward a context-
  # oriented approach in which we'll just pass the context directly into the
  # export classes and will pull the data off of that, but for now in order to
  # maintain the integrity of the Analytics::Export::Model classes we need to
  # provide the export data from this hash.
  #
  def export_data
    @export_data ||= {
      events: events,
      predictor_events: predictor_events,
      user_pageviews: user_pageviews[:results],
      user_predictor_pageviews: user_predictor_pageviews[:results],
      user_logins: user_logins[:results],
      users: users,
      assignments: assignments
    }
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
  # This whole process is kind of a black box right now because the
  # Analytics::Aggregate library is very dense, so it's not immediately clear
  # with more work than is warranted in this PR how to condense some of the
  # query overhead of this data.
  #
  # Perhaps we can reimagine Analytics::Aggregate as an all-ruby filtering
  # process for Mongoid collections so that we can, for example, just fetch
  # all of the pageviews one time and then get the aggregate data that we need
  # from it without making multiple queries.
  #
  # Or rather, perhaps we can share more of the filtering overhead between
  # mongo and ruby to reduce the amount of time that all of this raw querying
  # takes on such enormous amounts of data.
  #
  def user_pageviews
    @user_pageviews ||= CourseUserPageview.data :all_time, nil,
      { course_id: course.id },
      { page: "_all" }
  end

  def user_predictor_pageivews
    @user_predictor_pageviews ||=
      CourseUserPagePageview.data :all_time, nil,
        { course_id: course.id, page: /predictor/ }
  end

  def user_logins
    @user_logins ||= CourseUserLogin.data :all_time, nil,
      { course_id: course.id }
  end

  # ActiveRecord queries
  #
  def users
    @users ||= User.where(id: user_ids).select :id, :username
  end

  def assignments
    @assignments ||= Assignment.where(id: assignment_ids).select :id, :name
  end

  # Methods parsing the ids from the ActiveRecord queries
  #
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
