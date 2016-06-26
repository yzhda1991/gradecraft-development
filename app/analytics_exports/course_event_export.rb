class CourseEventExport < Analytics::Export::Model

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
  # being delegated to the #user_role method on the target record for export,
  # which in this case is a mongo event coming from context[:mongoid][:events]
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
  # Also consider that for the time being we're pulling all of this data from
  # the context hash so we can query for all of the data one time and use it
  # in multiple exports. In future pull requests this should be converted into
  # an Analytics::Export::Context class that can make traversing this data
  # more straightforward than calling nested hash keys.
  #
  def initialize(context:)
    @context = context
    @export_records = context[:mongoid][:events]

    # we're not actually exporting any users here, but we're going to use the
    # user data we queried through ActiveRecord to populate usernames for each
    # record. This saves us from having to have stored these in mongo which
    # would be redundant and painful
    #
    @users = context[:active_record][:users]
  end

  def usernames
    @usernames ||= users.inject({}) do |memo, user|
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
