class CourseEventExport < Analytics::Export::Model

  # this is the mapping of the columns in our export to the key that should
  # be used to filter or render the data in the row. For example:
  #
  # role: :user_role
  #
  # On the second line of this hash we say that we should have a column in the
  # final export called "role", and we should use the "user_role" method to get
  # the data that we want for the records in that column.
  #
  column_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 page: :page,
                 date_time: :formatted_event_timestamp

  def initialize(context:)
    @context = context

    # use events as the basis of the export
    @export_records = context.events
  end

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
