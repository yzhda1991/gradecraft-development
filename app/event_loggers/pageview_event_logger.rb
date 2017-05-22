class PageviewEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :pageview_event_logger

  attr_accessor :page

  # used by enqueuing methods in EventLogger::Enqueue
  def event_type
    "pageview"
  end

  def event_attrs
    application_attrs.merge page: page
  end

  def page
    @page ||= event_session[:request].try(:original_fullpath)
  end

  # params method is defined in ApplicationEventLogger
  def build_page_from_params
    return if params.nil? || !params[:url].present?
    @page = "#{params[:url]}#{params[:tab]}"
  end
end
