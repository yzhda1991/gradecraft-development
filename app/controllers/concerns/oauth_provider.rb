module OAuthProvider
  extend ActiveSupport::Concern
  include ExternalAuthorization

  class_methods do
    def oauth_provider_param(param)
      @@oauth_provider_param = param
    end
  end

  protected

  def redirect_path(path)
    session[:return_to] = path
  end

  def require_authorization
    provider = params.fetch @@oauth_provider_param
    require_authorization_with provider
  end

  def require_authorization_with(provider)
    validate_authorization(provider)
  end
end
