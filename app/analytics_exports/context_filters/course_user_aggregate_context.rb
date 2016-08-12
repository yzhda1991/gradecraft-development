class UserAggregateContextFilter < Analytics::Export::ContextFilter

  valid_contexts :course_export_context

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
end
