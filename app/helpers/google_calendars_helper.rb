require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets.rb'
require 'googleauth'

module GoogleCalendarsHelper
  Calendar = Google::Apis::CalendarV3

  def get_google_authorization(current_user)
    google_authorization = current_user.authorizations.find_by(provider: "google_oauth2")
    refresh_if_google_authorization_is_expired(google_authorization)
    google_authorization
  end

  def refresh_if_google_authorization_is_expired(google_authorization)
    return unless google_authorization.expired?
    google_authorization.refresh!({ client_id: ENV["GOOGLE_CLIENT_ID"], client_secret: ENV["GOOGLE_SECRET"] })
  end

  def google_auth_present?(current_user)
    current_user.authorizations.find_by(provider: "google_oauth2").present?
  end

  def create_google_event(event)
    google_event = Calendar::Event.new({
      summary: event.name,
      start: {
        date_time: event.open_at.to_datetime.rfc3339
      },
      end: {
        date_time: event.due_at.to_datetime.rfc3339
      }
    })
    google_event
  end

  def create_google_event_from_assignment(assignment)
    google_event = Calendar::Event.new({
      summary: assignment.name,
      description: assignment.description,
      start: {
        date_time: (assignment.due_at - 30.minutes).to_datetime.rfc3339
      },
      end: {
        date_time: assignment.due_at.to_datetime.rfc3339
      }
    })
    google_event
  end

  def create_google_secrets(google_authorization)
    Google::APIClient::ClientSecrets.new({"web" =>
      {"access_token" => google_authorization.access_token,
        "refresh_token" => google_authorization.refresh_token,
        "client_id" => ENV['GOOGLE_CLIENT_ID'],
        "client_secret" => ENV['GOOGLE_SECRET']}
        })
  end
end
