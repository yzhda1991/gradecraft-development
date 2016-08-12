class CourseEventExport < Analytics::Export::Model

  # what is the base set of records we'd like to use from the context to
  # generate this export? These records will translate to rows on the final
  # export csv.
  #
  export_records :events

  # map the column name to the attribute or method name on the record that we'd
  # like to use to populate each row
  #
  column_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 page: :page,
                 date_time: :formatted_event_timestamp

  # these are the methods being used to filter the 'row' values for the final
  # export CSV.
  #
  def username(event)
    context.usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def page(event)
    event.try(:page) || "[n/a]"
  end

  def formatted_event_timestamp(event)
    event.created_at.to_formatted_s :db
  end
end
