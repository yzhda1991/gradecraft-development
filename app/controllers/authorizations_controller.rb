class AuthorizationsController < ApplicationController
  def create
    UserAuthorization.create_by_auth_hash auth_hash, current_user

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to || root_path
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
