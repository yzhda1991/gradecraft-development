require_relative "../../services/activates_user"
require_relative "../../services/creates_new_user"

# rubocop:disable AndOr
class Integrations::GoogleController < ApplicationController
  include OAuthProvider

  layout "external", only: :new_user

  skip_before_action :require_login, only: :auth_callback
  skip_before_action :require_course_membership

  before_action :ensure_app_environment?, only: :new_user
  before_action -> do
    require_authorization_with(:google_oauth2)
  end, except: :auth_callback

  def new_user
  end

  # After the user confirms that their role is an instructor,
  # activate the account and direct them to the course shell creation page
  def confirm_instructor_role
    ensure_activated
    redirect_to new_external_courses_path user_id: current_user.id
  end

  # The Omniauth callback method
  # /auth/google_oauth2/callback
  def auth_callback
    if !logged_in?
      user = User.find_by_email auth_hash["info"]["email"]

      if user.nil?
        redirect_to errors_path(status_code: 401, error_type: "account_not_found") \
          and return if !Rails.env.beta?
        user = Services::CreatesNewUser.call(user_attributes)[:user]
        new_user = true
      end

      auto_login user
    end

    ensure_activated if session[:activate_google_user] == true
    create_user_authorization
    redirect_to redirect_path(new_user)
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_attributes
    {
      first_name: auth_hash["info"]["first_name"],
      last_name: auth_hash["info"]["last_name"],
      username: auth_hash["info"]["email"],
      email: auth_hash["info"]["email"]
    }
  end

  def ensure_activated
    Services::ActivatesUser.call(current_user) if !current_user.activated?
  end

  def create_user_authorization
    UserAuthorization.create_by_auth_hash auth_hash, current_user
  end

  def redirect_path(is_new_user)
    return_to = session[:return_to]
    session[:return_to] = nil

    if session[:activate_google_user] == true
      session[:activate_google_user] = nil
      new_external_courses_path user_id: current_user.id
    elsif is_new_user
      new_user_google_path
    else
      return_to || root_path
    end
  end
end
