class GoogleCalendarsController < ApplicationController
  include GoogleCalendarsHelper
  include OAuthProvider

  oauth_provider_param :google_oauth2
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets.rb'
  require 'googleauth'

  before_action do |controller|
    controller.redirect_path events_path
  end

  Calendar = Google::Apis::CalendarV3

  def add_event_to_google_calendar
    if !google_auth_present?(current_user)
      # rubocop:disable AndOr
      redirect_to "/auth/google_oauth2" and return
    end
    google_authorization = get_google_authorization(current_user)
    event = current_course.events.find(params[:id])
    if event.open_at.nil? || event.due_at.nil?
      redirect_to events_path, alert: "Google Calendar requires event have both START and END time!"
    else
      begin
        google_event = create_google_event(event)
        calendar = Calendar::CalendarService.new
        client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'])
        secrets = create_google_secrets(google_authorization)
        calendar.authorization = secrets.to_authorization
        calendar.authorization.refresh!
        result = calendar.insert_event('primary', google_event)
        redirect_to events_path, notice: "Event " + event.name + " successfully added to your Google Calendar"
      rescue Google::Apis::ServerError, Google::Apis::ClientError, Google::Apis::AuthorizationError, Signet::AuthorizationError
        redirect_to events_path, alert: "Google Calendar encountered an Error. Your event was NOT copied to your Google calendar."
      end
    end
  end

  def add_assignment_to_google_calendar
    if !google_auth_present?(current_user)
      # rubocop:disable AndOr
      redirect_to "/auth/google_oauth2" and return
    end
    google_authorization = get_google_authorization(current_user)
    assignment = current_course.assignments.find(params[:id])
    if assignment.due_at.nil?
      redirect_to assignments_path, alert: "Google Calendar requires assignment have at least END time!"
    else
      begin
        google_event = create_google_event_from_assignment(assignment)
        calendar = Calendar::CalendarService.new
        client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'])
        secrets = create_google_secrets(google_authorization)
        calendar.authorization = secrets.to_authorization
        calendar.authorization.refresh!
        result = calendar.insert_event('primary', google_event)
        redirect_to assignments_path, notice: "Assignment " + assignment.name + " successfully added to your Google Calendar"
      rescue Google::Apis::ServerError, Google::Apis::ClientError, Google::Apis::AuthorizationError, Signet::AuthorizationError
        redirect_to assignments_path, alert: "Google Calendar encountered an Error. Your assignment was NOT copied to your Google calendar."
      end
    end
  end

end
