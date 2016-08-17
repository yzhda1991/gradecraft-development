module OAuthProvider
  extend ActiveSupport::Concern

  protected

  def unauthorized_path(path)
    session[:return_to] = path
  end

  def require_authorization
    provider = params[:importer_provider_id]
    require_authorization_with provider
  end

  def require_authorization_with(provider)
    auth = authorization(provider)

    if auth.nil?
      redirect_to "/auth/#{provider}",
        notice: "You could not be authorized with #{provider.capitalize}."
    elsif auth.expired?
      config = ActiveLMS.configuration.providers[provider.to_sym]
      auth.refresh_with_config! config
    end
  end

  def authorization(provider)
    UserAuthorization.for(current_user, provider)
  end
end
