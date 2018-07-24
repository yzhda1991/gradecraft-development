# rubocop:disable AndOr
class Integrations::GoogleController < ApplicationController
  include OAuthProvider

  layout "external", only: :new_user

  skip_before_action :require_login, only: :auth_callback
  skip_before_action :require_course_membership
  
  before_action -> do
    redirect_path new_user_google_path
    require_authorization_with(:google_oauth2)
  end, only: :new_user

  def new_user
  end

  def auth_callback
    if !logged_in?
      user = User.find_by_email auth_hash["info"]["email"]

      if user.nil?
        user = create_new_user
        new_user = true
        user.activate!
      end

      auto_login user
    end

    create_user_authorization
    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to action: :new_user and return if new_user
    redirect_to return_to || root_path
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def create_new_user
    User.create(
      first_name: auth_hash["info"]["first_name"],
      last_name: auth_hash["info"]["last_name"],
      username: auth_hash["info"]["email"],
      email: auth_hash["info"]["email"]
    )
  end

  def create_user_authorization
    UserAuthorization.create_by_auth_hash auth_hash, current_user
  end
end
