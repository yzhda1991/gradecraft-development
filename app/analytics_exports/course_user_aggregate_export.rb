class CourseUserAggregateExport < Analytics::Export::Model

  attr_reader :events, :predictor_events, :users,
              :user_pageviews, :user_logins, :user_predictor_pageviews

  export_mapping username: :username,
             role: :user_role,
             user_id: :user_id,
             total_pageviews: :pageviews,
             total_logins: :logins,
             total_predictor_events: :predictor_events,
             total_predictor_sessions: :predictor_sessions

  def initialize(context:)
    @context = context

    # since this is a user aggregate, let's use the user records as the focus of
    # the export, as output rows, rather than the events themselves
    @export_records = context.users
  end

  def roles
    @roles ||= context.events.inject(Hash.new("")) do |memo, event|
      memo[event.user_id] = event.user_role
      memo
    end
  end

  def user_predictor_event_counts
    @user_predictor_event_counts ||= context.predictor_events
      .inject(Hash.new(0)) do |memo, predictor_event|
        memo[predictor_event.user_id] += 1
        memo
    end
  end

  def parsed_user_pageviews
    @parsed_user_pageviews ||= context.user_pageviews.inject(Hash.new(0)) do |memo, pageview|
      # pageview.pages raises an error w/ mongoid > 4.0.0
      memo[pageview.user_id] = pageview.raw_attributes["pages"]["_all"]["all_time"]
      memo
    end
  end

  def parsed_user_logins
    @parsed_user_logins ||= context.user_logins.inject(Hash.new(0)) do |memo, login|
      memo[login.user_id] = login["all_time"]["count"]
      memo
    end
  end

  def user_predictor_sessions
    @user_predictor_sessions ||= context.user_predictor_pageviews.inject(Hash.new(0)) do |memo, predictor_pageview|
      memo[predictor_pageview.user_id] = predictor_pageview["all_time"]
      memo
    end
  end

  # column filters for
  def user_role(user)
    roles[user.id]
  end

  def pageviews(user)
    parsed_user_pageviews[user.id]
  end

  def logins(user)
    user_logins[user.id]
  end

  def predictor_events(user)
    user_predictor_event_counts[user.id]
  end

  def predictor_sessions(user)
    user_predictor_sessions[user.id]
  end

  def user_id(user)
    user.id
  end
end
