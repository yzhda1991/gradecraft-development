class GoogleCalendarsController < ApplicationController
  include GoogleCalendarsHelper
  include OAuthProvider

  oauth_provider_param :google_oauth2
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets.rb'
  require 'googleauth'

  before_action do |controller|
    controller.redirect_path request.referer
  end

  Calendar = Google::Apis::CalendarV3

  def add_to_google_calendar
    if !google_auth_present?(current_user)
      # rubocop:disable AndOr
      redirect_to "/auth/google_oauth2" and return
    end
    google_authorization = get_google_authorization(current_user)
    item = get_event_or_assignment(params[:class], params[:id])
    if item.due_at.nil?
      redirect_to get_path(params[:class]), alert: "Google Calendar requires " + params[:class] + " have at least END time!" and return
    end
    begin
      google_event = create_google_event(item)
      calendar = Calendar::CalendarService.new
      client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'])
      secrets = create_google_secrets(google_authorization)
      calendar.authorization = secrets.to_authorization
      calendar.authorization.refresh!
      result = calendar.insert_event('primary', google_event)
      redirect_to get_path(params[:class]), notice: params[:class].capitalize + " " + item.name + " successfully added to your Google Calendar"
    rescue Google::Apis::ServerError, Google::Apis::ClientError, Google::Apis::AuthorizationError, Signet::AuthorizationError
      redirect_to get_path(params[:class]), alert: "Google Calendar encountered an Error. Your " + params[:class] + " was NOT copied to your Google calendar."
    end
  end

end
