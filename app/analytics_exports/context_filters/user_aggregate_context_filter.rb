# The notion of this class is that we'd like to produce an entire course export
# archive using a single export context so we don't need to perform several
# massive, coursewide data queries for each export. It might be used like this:
#
# However since the CourseUserAggregateExport needs to organize the data
# differently for presentation, we've added this filter class as a sort of
# export presenter layer for the context we've already constructed and queried.
#
# These methods were originally being defined in the CourseUserAggregateExport
# itself, but it seemed like a more succinct workflow to keep these methods
# together since they're all doing the same thing. Some helper methods for
# determining compatibility with various context types are defined in the
# ::ContextFilter class.
#
class UserAggregateContextFilter < Analytics::Export::ContextFilter

  # this filter only accepts instances of the CourseExportContext context
  accepts_context_types :course_export_context

  # what are the roles for each user in this course?
  def user_roles
    @user_roles ||= context.events.inject(Hash.new("")) do |memo, event|
      memo[event.user_id] = event.user_role
      memo
    end
  end

  # how many predictor events does each user have?
  def user_predictor_event_counts
    @user_predictor_event_counts ||= context.predictor_events
      .inject(Hash.new(0)) do |memo, predictor_event|
      memo[predictor_event.user_id] += 1
      memo
    end
  end

  # how many pageviews does each user have for the course?
  def parsed_user_pageviews
    @parsed_user_pageviews ||= context.user_pageviews.inject(Hash.new(0)) do |memo, aggregate_result|
      memo[aggregate_result.user_id] = aggregate_result.raw_attributes["pages"]["_all"]["all_time"]
      memo
    end
  end

  # how many times has the user logged into a course session?
  def parsed_user_logins
    @parsed_user_logins ||= context.user_logins.inject(Hash.new(0)) do |memo, login|
      memo[login.user_id] = login["all_time"]["count"]
      memo
    end
  end

  # how many times has each user visited the predictor utility for this class?
  def user_predictor_sessions
    @user_predictor_sessions ||= context.user_predictor_pageviews.inject(Hash.new(0)) do |memo, predictor_pageview|
      memo[predictor_pageview.user_id] = predictor_pageview["all_time"]
      memo
    end
  end
end
