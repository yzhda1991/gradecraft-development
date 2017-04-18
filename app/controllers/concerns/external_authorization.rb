module ExternalAuthorization
  extend ActiveSupport::Concern

  protected

  def validate_authorization(provider)
    auth = authorization(provider)

    if auth.nil?
      respond_to do |format|
        format.html { redirect_to "/auth/#{provider}" }
        format.json do
          render json: { errors: [{ detail: "Unauthorized" }], success: false },
            status: 401
        end
      end
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
