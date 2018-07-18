# rubocop:disable AndOr
class Integrations::GoogleController < ApplicationController
  include OAuthProvider

  skip_before_action :require_login
  skip_before_action :require_course_membership

  # TODO: these routes need to be protected by a current OAuth session
  # before_action -> { require_authorization_with(:google_oauth2) }, except: :auth_callback

  def new_user
  end

  def create_user
    user = User.create user_params
    user.activate!
    redirect_to new_external_courses_path user_id: user.id
  end

  def auth_callback
    if logged_in?
      create_user_authorization
    else
      user = User.find_by_email auth_hash["info"]["email"]
      if user.nil?
        session[:google_omniauth_user] = {
          email: auth_hash["info"]["email"],
          first_name: auth_hash["info"]["first_name"],
          last_name: auth_hash["info"]["last_name"]
        }
        redirect_to action: :new_user and return
      else
        auto_login user
        create_user_authorization
      end
    end

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to || root_path
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def create_user_authorization
    UserAuthorization.create_by_auth_hash auth_hash, current_user
  end

  def user_params
    attr = session[:google_omniauth_user]
    {
      email: attr["email"],
      first_name: attr["first_name"],
      last_name: attr["last_name"],
      username: attr["email"]
    }
  end
end
