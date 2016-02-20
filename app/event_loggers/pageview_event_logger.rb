class PageviewEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue

  # queue to use for login event jobs
  @queue = :pageview_event_logger
  @event_name = "Pageview"

  attr_writer :page

  # instance methods
  def event_type
    "pageview"
  end

  def event_attrs
    @event_attrs ||= base_attrs.merge page: page
  end

  def page
    @page ||= event_session[:request].try(:original_fullpath)
  end

  # params method is defined in ApplicationEventLogger
  def build_page_from_params
    if params and params[:url] and params[:tab]
      @page = "#{params[:url]}#{params[:tab]}"
    end
  end
end
