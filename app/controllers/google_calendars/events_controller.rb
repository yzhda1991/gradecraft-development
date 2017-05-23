class GoogleCalendars::EventsController < ApplicationController
  include GoogleCalendarsHelper
  include OAuthProvider

  oauth_provider_param :google_oauth2
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets.rb'
  require 'googleauth'

  before_action do |controller|
    controller.redirect_path request.referer
  end

  before_action :redirect_if_auth_not_present

  Calendar = Google::Apis::CalendarV3

  def add_event
    event = get_item(current_course, "event", params[:id])
    if event.due_at.nil?
      redirect_to event, alert: "Google Calendar requires Event to have at least END time!" and return
    end
    item_hash = add_single_item(current_user, event)
    process_hash(item_hash)
  end

  def add_events
    event_list = get_all_items_for_current_course(current_course, "event")
    event_list_filtered = filter_items_with_no_end_date(event_list)
    items_hash = add_multiple_items(current_user, event_list, event_list_filtered)
    items_hash.store("redirect_to", events_path)
    process_hash(items_hash)
  end

end #class
