class CanvasSessionController < ApplicationController
  before_action :ensure_admin?

  def new
    if current_canvas_institution.present?
      request.env['omniauth.strategy'].options[:client_id] =
        current_canvas_institution.consumer_key
      request.env['omniauth.strategy'].options[:client_secret] =
        current_canvas_institution.decrypted_consumer_secret
      request.env['omniauth.strategy'].options[:client_options]
        .merge! ActiveLMS.configuration.providers[:canvas].client_options
    end
    render plain: "Omniauth setup phase."
  end
end
