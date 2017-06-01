require "active_lms"
require_relative "../../services/imports_lms_users"

class Users::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action except: :index do |controller|
    controller.redirect_path \
      users_importer_users_path(params[:importer_provider_id], params[:id])
  end
  before_action :link_canvas_credentials, if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization, except: [:index, :download]

  # GET /users/importers/:importer_provider_id/users
  def users
    @provider_name = params[:importer_provider_id]
  end

  # GET /users/download
  # Sends a CSV file to the user with a sample list of users in the proper format
  def download
    respond_to do |format|
      format.csv do
        file = generate_csv
        send_data file,
          filename: "Sample Users File - #{ Date.today}.csv"
      end
    end
  end

  # POST /users/importers/:importer_provider_id/course/:id/users/import
  def users_import
    @provider_name = params[:importer_provider_id]

    @result = Services::ImportsLMSUsers.import @provider_name,
      authorization(@provider_name).access_token, params[:id], params[:user_ids],
      current_course

    if @result.success?
      render :user_import_results
    else
      redirect_to users_importer_users_path(params[:importer_provider_id], params[:id]),
        alert: "Failed to import #{params[:importer_provider_id]} users"
    end
  end
end

private

def generate_csv(options={})
  CSV.generate(options) do |csv|
    csv << user_headers
    csv << user_a_details
    csv << user_b_details
  end
end

def user_headers
  ["First Name", "Last Name", "Username", "Email", "Team Name"].freeze
end

def user_a_details
  ["John", "Doe", "johnd", "johnd@school.edu", "Team Doe"].freeze
end

def user_b_details
  ["Jane", "Doe", "janed", "janed@school.edu", "Team Doe"].freeze
end
