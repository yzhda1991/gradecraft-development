class SamlController < ApplicationController
  skip_before_filter :require_login, :except => [:logout]
  
  def init
    Rails.logger.debug params
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(SAML_SETTINGS))
  end

  def consume
    Rails.logger.debug params
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
    response.settings = SAML_SETTINGS
    if response.is_valid?
      #user already exists
    else
      #not valid
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(SAML_SETTINGS, true)
  end

  def logout
    #TODO
    Rails.logger.debug params
  end


end
