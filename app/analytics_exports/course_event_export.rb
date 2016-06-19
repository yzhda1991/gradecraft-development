class CourseEventExport
  include Analytics::Export::Model

  rows_by :events

  set_schema  username: :username,
              role: :user_role,
              user_id: :user_id,
              page: :page,
              date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  def schema_records_for_role(role)
    parsed_schema_records records.select do |event|
      event.user_role == role
    end
  end

  def initialize(loaded_data)
    @loaded_data = loaded_data
    @usernames = loaded_data[:users].inject({}) do |hash, user|
      hash[user.id] = user.username
      hash
    end
  end

  def username(event, index)
    @usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def page(event, index)
    event.try(:page) || "[n/a]"
  end
end
