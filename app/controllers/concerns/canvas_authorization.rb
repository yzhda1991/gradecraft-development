module CanvasAuthorization
  extend ActiveSupport::Concern

  protected

  # Ensure configuration is up to date with credentials for the current course
  # if they were stored in the Provider table
  def link_canvas_credentials
    linked_provider = Provider.for_course current_course
    return if linked_provider.nil?

    ActiveLMS.configuration.providers[:canvas].base_uri =
      linked_provider.base_url
    ActiveLMS.configuration.providers[:canvas].client_id =
      linked_provider.consumer_key
    ActiveLMS.configuration.providers[:canvas].client_secret =
      linked_provider.consumer_secret
    ActiveLMS.configuration.providers[:canvas].client_options = {
      site: "#{linked_provider.base_url}/login/canvas"
    }
  end
end
