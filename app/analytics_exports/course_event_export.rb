class CourseEventExport
  include Analytics::Export::Model

  attr_reader :users

  rows_by :events

  set_schema  username: :username,
              role: :user_role,
              user_id: :user_id,
              page: :page,
              date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  def initialize(context:)
    @context = context
    @users = context[:active_record][:users]
  end

  def usernames
    @usernames = users.inject({}) do |memo, user|
      memo[user.id] = user.username
      memo
    end
  end

  def username(event)
    usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def page(event)
    event.try(:page) || "[n/a]"
  end
end
