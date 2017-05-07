module ExternalAuthorization
  extend ActiveSupport::Concern

  protected

  def validate_authorization(provider)
    set_linked_provider_credentials(provider)
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

  private

  # Ensure configuration is up to date with credentials for the current course
  # if they were stored in the Provider table
  def set_linked_provider_credentials(provider)
    linked_provider = Provider.for current_course

    unless provider.nil?
      ActiveLMS.configuration.providers[provider.to_sym].base_uri =
        linked_provider.base_url
      ActiveLMS.configuration.providers[provider.to_sym].client_id =
        linked_provider.consumer_key
      ActiveLMS.configuration.providers[provider.to_sym].client_secret =
        linked_provider.consumer_secret
    end
  end
end
