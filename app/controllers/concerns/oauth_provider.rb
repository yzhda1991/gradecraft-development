module OAuthProvider
  extend ActiveSupport::Concern

  private

  def require_authorization
    provider = params[:importer_provider_id]
    require_authorization_with provider
  end

  def require_authorization_with(provider)
    auth = authorization(provider)

    if auth.nil?
      session[:return_to] = assignments_importers_path(provider)
      redirect_to "/auth/#{provider}"
    elsif auth.expired?
      config = ActiveLMS.configuration.providers[provider.to_sym]
      auth.refresh_with_config! config
    end
  end

  def authorization(provider)
    UserAuthorization.for(current_user, provider)
  end
end
