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

  def initialize(course:)
    @course = course
  end

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

  def events
    @events ||= Analytics::Event.where(course_id: course.id)
  end

  def predictor_events
    @predictor_events ||= Analytics::Event.where \
      course_id: course.id,
      event_type: "predictor"
  end

  def user_pageviews
    @user_pageviews ||= CourseUserPageview.data(:all_time, nil, {
      course_id: course.id
      },
      { page: "_all" })
  end

  def user_predictor_pageivews
    @user_predictor_pageviews ||=
      CourseUserPagePageview.data(:all_time, nil, {
      course_id: course.id, page: /predictor/
      })
  end

  def user_logins
    @user_logins ||= CourseUserLogin.data(:all_time, nil, {
      course_id: course.id
      })
  end

  def users
    @users ||= User.where(id: user_ids).select(:id, :username)
  end

  def assignments
    @assignments ||= Assignment.where(id: assignment_ids).select(:id, :name)
  end

  def user_ids
    @user_ids ||= events.collect(&:user_id).compact.uniq
  end

  def assignment_ids
    @assignment_ids ||= events.select {
      |event| event.respond_to? :assignment_id
    }.collect(&:assignment_id).compact.uniq
  end
end
