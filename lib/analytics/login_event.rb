module Analytics
  # this class inherits from Event since it is the only type of event that
  # should have a :last_login_at field, but is otherwise identical to
  # Analytics::Event. This will still be logged in the AnalyticsEvents
  # collection in Mongo, but will have the additional _type of
  # Analytics::LoginEvent instead of Analytics::Event
  class LoginEvent < Analytics::Event
    field :last_login_at, type: DateTime
  end
end
