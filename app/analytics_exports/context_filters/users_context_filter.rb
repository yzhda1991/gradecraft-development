class UsersContextFilter < Analytics::Export::ContextFilter
  # this filter only accepts instances of the CourseExportContext context
  accepts_context_types :course_export_context

  def usernames
    @usernames ||= context.users.inject({}) do |memo, user|
      memo[user.id] = user.username
      memo
    end
  end
end
