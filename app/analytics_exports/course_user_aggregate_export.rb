require_relative "./context_filters/user_aggregate_context_filter"

class CourseUserAggregateExport < Analytics::Export::Model

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

  # filters add an extra layer of parsing on top of the base context queries
  #
  context_filters :user_aggregate

  # add and alias for the filter since we're using it globally
  def context_filter
    user_aggregate_context_filter
  end

  # column parsing methods
  #
  def user_role(user)
    context_filter.user_roles[user.id]
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
end
