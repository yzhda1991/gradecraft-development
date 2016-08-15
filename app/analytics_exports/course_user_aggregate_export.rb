require_relative "./context_filters/user_aggregate_context_filter"

class CourseUserAggregateExport < Analytics::Export::Model

  attr_reader :events, :predictor_events, :users,
              :user_pageviews, :user_logins, :user_predictor_pageviews

  # what is the base set of records we'd like to use from the context to
  # generate this export. These records will translate to rows on the final
  # export csv.
  #
  export_focus :users

  # map the column name to the attribute or method name on the record that we'd
  # like to use to populate each row
  #
  column_mapping username: :username,
                 role: :user_role,
                 user_id: :id,
                 total_pageviews: :pageviews,
                 total_logins: :logins,
                 total_predictor_events: :predictor_events,
                 total_predictor_sessions: :predictor_sessions

  # column filters
  def user_role(user)
    context_filter.roles[user.id]
  end

  def pageviews(user)
    context_filter.parsed_user_pageviews[user.id]
  end

  def logins(user)
    context_filter.user_logins[user.id]
  end

  def predictor_events(user)
    context_filter.user_predictor_event_counts[user.id]
  end

  def predictor_sessions(user)
    context_filter.user_predictor_sessions[user.id]
  end

  # add a context filter for the context itself, since we don't want to
  # re-query for all the data it provides, but we also don't want to
  # jam it into the export model
  #
  def context_filter
    @context_filter ||= UserAggregateContextFilter.new context
  end
end
