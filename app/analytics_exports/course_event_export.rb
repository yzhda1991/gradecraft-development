require_relative "context_filters/users_context_filter"

class CourseEventExport < Analytics::Export::Model

  # what is the base set of records we'd like to use from the context to
  # generate this export. These records will translate to rows on the final
  # export csv.
  #
  export_focus :events

  # map the column name to the attribute or method name on the record that we'd
  # like to use to populate each row
  #
  column_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 page: :page,
                 date_time: :formatted_event_timestamp

  # filters add an extra layer of parsing on top of the base context queries
  #
  context_filters :users

  # column parsing methods
  #
  def username(event)
    context_filters[:users].usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def page(event)
    event.try(:page) || "[n/a]"
  end

  def formatted_event_timestamp(event)
    # this is the equivalent of %Y-%m-%d %H:%M:%S
    event.created_at.strftime "%F %T"
  end
end
