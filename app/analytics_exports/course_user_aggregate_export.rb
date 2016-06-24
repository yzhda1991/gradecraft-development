class CourseUserAggregateExport
  include Analytics::Export::Model

  rows_by :users

  set_schema username: :username,
             role: :user_role,
             user_id: :user_id,
             total_pageviews: :pageviews,
             total_logins: :logins,
             total_predictor_events: :predictor_events,
             total_predictor_sessions: :predictor_sessions

  def schema_records_for_role(role)
    parsed_schema_records records.select {|user| @roles[user.id] == role }
  end

  def initialize(context:)
    @context = context
    @events = context[:mongoid][:events]
    @predictor_events = context[:mongoid][:predictor_events]

    @user_pageviews = context[:data_aggregates][:user_pageviews]
    @user_logins = context[:data_aggregates][:user_logins]
    @user_logins = context[:data_aggregates][:user_predictor_pageviews]
  end

  # let's double-check whether all of these defaulted hash instantiations have
  # any impact on the final export. It seems like these could all just be hash
  # literals
  #
  def roles
    @roles ||= events.inject(Hash.new("")) do |memo, event|
      memo[event.user_id] = event.user_role
      memo
    end
  end

  def user_predictor_event_counts
    @user_predictor_event_counts ||= predictor_events
      .inject(Hash.new(0)) do |memo, predictor_event|
        memo[predictor_event.user_id] += 1
        memo
    end
  end

  def parsed_user_pageviews
    @parsed_user_pageviews ||= user_pageviews.inject(Hash.new(0)) do |memo, pageview|
      # pageview.pages raises an error w/ mongoid > 4.0.0
      memo[pageview.user_id] = pageview.raw_attributes["pages"]["_all"]["all_time"]
      memo
    end
  end

  def parsed_user_logins
    @parsed_user_logins ||= user_logins.inject(Hash.new(0)) do |memo, login|
      memo[login.user_id] = login["all_time"]["count"]
      memo
    end
  end

  def user_predictor_sessions
    @user_predictor_sessions ||= user_predictor_pageviews.inject(Hash.new(0)) do |hash, predictor_pageview|
      hash[predictor_pageview.user_id] = predictor_pageview["all_time"]
      hash
    end
  end

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
