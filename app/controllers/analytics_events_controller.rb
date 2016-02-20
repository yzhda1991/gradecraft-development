class AnalyticsEventsController < ApplicationController
  skip_before_filter :increment_page_views

  def predictor_event
    # limited to 5 predictor jobs/second in Resque initializer
    PredictorEventLogger.new(event_session_with_params).enqueue_with_fallback

    render :nothing => true, :status => :ok
  end

  def tab_select_event
    # limited to 20 pageview jobs/second in Resque initializer
    # only run at night during the Lull period
    PageviewEventLogger.new(event_session_with_params)
      .build_page_from_params
      .enqueue_in(Lull.time_until_next_lull)

    render :nothing => true, :status => :ok
  end

  protected

  def event_session_with_params
    event_session.merge params
  end
end
