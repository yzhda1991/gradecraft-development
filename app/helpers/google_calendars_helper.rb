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

  def get_event_or_assignment(class_name, id)
    if class_name == "event"
      return current_course.events.find(id)
    end
    if class_name == "assignment"
      return current_course.assignments.find(id)
    end
  end

  def get_path(class_name)
    if class_name == "assignment"
      return assignments_path
    end
    if class_name == "event"
      return events_path
    end
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
        date_time: (generate_open_date_if_one_does_not_exist(assignment)).to_datetime.rfc3339
      },
      end: {
        date_time: assignment.due_at.to_datetime.rfc3339
      }
    })
    google_event
  end

  def generate_open_date_if_one_does_not_exist(assignment)
    if assignment.open_at.nil?
      assignment.due_at - 30.minutes
    else
      assignment.open_at
    end
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
