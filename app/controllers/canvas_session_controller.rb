class CanvasSessionController < ApplicationController
  before_action :ensure_admin?

  def new
    canvas_provider = Provider.for_course current_course
    configure_omniauth_options canvas_provider if canvas_provider.present?
    render plain: "Omniauth setup phase."
  end

  private

  def configure_omniauth_options(provider)
    request.env["omniauth.strategy"].options[:client_id] =
      provider.consumer_key
    request.env["omniauth.strategy"].options[:client_secret] =
      provider.consumer_secret
    request.env["omniauth.strategy"].options[:client_options].site =
      "#{provider.base_url}/login/canvas"
  end
end
