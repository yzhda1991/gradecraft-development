module OAuthProvider
  extend ActiveSupport::Concern
  include ExternalAuthorization

  included do
    self.provider_param = nil
  end

  class_methods do
    attr_accessor :provider_param

    def oauth_provider_param(param)
      @provider_param = param
    end
  end

  protected

  def redirect_path(path)
    session[:return_to] = path
  end

  def require_authorization
    provider = params.fetch self.class.provider_param
    require_authorization_with provider
  end

  def require_authorization_with(provider)
    validate_authorization(provider)
  end
end
