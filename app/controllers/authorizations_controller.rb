require_relative "../services/creates_or_updates_user"

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
      @user = User.find_by_email(request.env["omniauth.auth"]["info"]["email"])
      if @user.nil?
        google_user = {username: auth_hash['email'],
          first_name: auth_hash['first_name'], last_name: auth_hash['last_name'],
          email: auth_hash['email']}
        redirect_to confirmation_path google_user and return
      end
      @user.activate!
      auto_login @user if current_user.nil?
    rescue
      redirect_to auth_failure_path and return
    end
  end

  def auth_hash
    request.env['omniauth.auth']['info']
  end

  def is_google?
    self.params[:provider] == "google_oauth2"
  end
end
