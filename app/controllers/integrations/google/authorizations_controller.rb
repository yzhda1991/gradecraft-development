class Integrations::Google::AuthorizationsController < ApplicationController
  include OAuthProvider

  skip_before_action :require_login, only: :callback
  skip_before_action :require_course_membership, only: :callback
  before_action -> { require_authorization_with(:google_oauth2) }, only: :callback
  before_action { |controller| controller.redirect_path request.referer }

  def callback
    if logged_in?
      create_user_authorization
    else
      user = User.find_by_email auth_hash["email"]
      if user.nil?
        session[:google_omniauth_user] = {
          email: auth_hash["email"],
          first_name: auth_hash["first_name"],
          last_name: auth_hash["last_name"]
        }
        redirect_to confirmation_path and return
      else
        create_user_authorization
        # user.activate! unless user.activated? # TODO: this wherever we ultimately create the user
        auto_login user
      end
    end

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to || root_path
  end

  private

  def auth_hash
    request.env["omniauth.auth"]["info"]
  end

  def create_user_authorization
    UserAuthorization.create_by_auth_hash auth_hash, current_user
  end
end
