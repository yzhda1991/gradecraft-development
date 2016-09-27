module ExternalAuthorization
  extend ActiveSupport::Concern

  protected

  def validate_authorization(provider)
    auth = authorization(provider)

    if auth.nil?
      redirect_to "/auth/#{provider}"
    elsif auth.expired?
      config = ActiveLMS.configuration.providers[provider.to_sym]
      auth.refresh_with_config! config
    end

    auth
  end

  def authorization(provider)
    UserAuthorization.for(current_user, provider)
  end
end
