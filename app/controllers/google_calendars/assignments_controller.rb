class GoogleCalendars::AssignmentsController < ApplicationController
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

  def add_assignment
    assignment = get_item(current_course, "assignment", params[:id])
    if assignment.due_at.nil?
      redirect_to assignment, alert: "Google Calendar requires Assignment to have at least END time!" and return
    end
    item_hash = add_single_item(current_user, assignment)
    process_hash(item_hash)
  end

  def add_assignments
    assignment_list = get_all_items_for_current_course(current_course, "assignment", current_user)
    assignment_list_filtered = filter_items_with_no_end_date(assignment_list)
    items_hash = add_multiple_items(current_user, assignment_list, assignment_list_filtered)
    items_hash.store("redirect_to", assignments_path)
    process_hash(items_hash)
  end

end #class
