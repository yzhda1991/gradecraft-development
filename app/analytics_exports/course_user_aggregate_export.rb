class CourseUserAggregateExport
  include Analytics::Export::Model

  attr_reader :events, :predictor_events, :users, :export_records,
              :user_pageviews, :user_logins, :user_predictor_pageviews

  set_schema username: :username,
             role: :user_role,
             user_id: :user_id,
             total_pageviews: :pageviews,
             total_logins: :logins,
             total_predictor_events: :predictor_events,
             total_predictor_sessions: :predictor_sessions

  def initialize(context:)
    @context = context
    @events = context[:mongoid][:events]
    @predictor_events = context[:mongoid][:predictor_events]

    # these are the additional records we queried from ActiveRecord to use for
    # adding context and data to our export columns related to assignments
    # and users
    #
    @users = context[:active_record][:users]

    # in this case we're using ActiveRecord User objects for the basis of our
    # export instead of Analytics::Event records out of Mongoid. We're still
    # using the mongoid data, but it's being referenced in each row from by the
    # id from the corresponding user.
    #
    @export_records = users

    # this is the data from the data aggregates that we queried in the original
    # context when the export was triggered. The entire data aggregate suite
    # really needs to be picked apart and improved due to its current density,
    # but for now that won't stop us from using the data that it helps to
    # assemble across various metrics.
    #
    @user_pageviews = context[:data_aggregates][:user_pageviews]
    @user_logins = context[:data_aggregates][:user_logins]
    @user_predictor_pageviews = context[:data_aggregates][:user_predictor_pageviews]
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
    @user_predictor_sessions ||= user_predictor_pageviews.inject(Hash.new(0)) do |memo, predictor_pageview|
      memo[predictor_pageview.user_id] = predictor_pageview["all_time"]
      memo
    end
  end

  # these are helper methods to help filter values per-user. In reality there's
  # probably a disconnect here in how this 'schema' is being defined and how the
  # data is ultimately being assembled.
  #
  # Instead of generating a hash of records for every column that we need to
  # display, then filtering all of them, I wonder if it makes more sense to
  # just construct a single hash, or to use a hash of procs that can be run
  # against all of these records one time so we don't need to generate a bunch
  # of different hashes and then put them back together.
  #
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
