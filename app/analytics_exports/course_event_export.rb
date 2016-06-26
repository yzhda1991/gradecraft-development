class CourseEventExport
  include Analytics::Export::Model

  attr_reader :users

  # this is the mapping of the columns in our export to the key that should
  # be used to filter or render the data in the row. For example:
  #
  # role: :user_role
  #
  # On the second line of this hash we say that we should have a column in the
  # final export called "role", and we should use the "user_role" method to get
  # the data that we want for the records in that column. Because we have no
  # "user_role" method on the export itself, we can presume that user_role is
  # being delegated to the #user_role method on the target record for export.
  #
  export_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 page: :page,
                 date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  # Remember that records: is the collection of mongo records that we're
  # ultimately going to filter. If we want to get more clever about how we're
  # defining this later we're welcome to, but for now let's just pass this
  # in since we're performing the queries for these records before the object
  # is constructed anyway.
  #
  def initialize(context:)
    @context = context
    @records = context[:mongoid][:events]
    @users = context[:active_record][:users]
  end

  def usernames
    @usernames = users.inject({}) do |memo, user|
      memo[user.id] = user.username
      memo
    end
  end

  # these are the methods being used to filter the 'row' values for the final
  # export CSV. There's probably a better way to organize them, but for now
  # let's at least keep them together and keep them commented.
  #
  # These correspond to the values in the export_mapping hash defined on the
  # class at the top of this file
  #
  def username(event)
    usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def page(event)
    event.try(:page) || "[n/a]"
  end
end
