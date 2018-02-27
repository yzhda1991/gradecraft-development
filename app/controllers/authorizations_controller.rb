class AuthorizationsController < ApplicationController

  skip_before_action :require_login, if: :is_google?
  skip_before_action :require_course_membership, if: :is_google?
  before_action :log_me_in, if: :is_google?

  def create
    UserAuthorization.create_by_auth_hash request.env["omniauth.auth"], current_user

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to || root_path
  end

  private

  def log_me_in
    begin
      auto_login User.find_by_email(request.env["omniauth.auth"]["info"]["email"]) if current_user.nil?
    rescue
      redirect_to auth_failure_path
    end
  end

  def is_google?
    self.params[:provider] == "google_oauth2"
  end
end
