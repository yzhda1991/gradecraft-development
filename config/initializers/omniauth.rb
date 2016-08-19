require_relative "active_lms"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :canvas, ActiveLMS.configuration.providers[:canvas].client_id,
    ActiveLMS.configuration.providers[:canvas].client_secret,
    setup: lambda { |env|
      env["omniauth.strategy"].options[:client_options]
        .merge! ActiveLMS.configuration.providers[:canvas].client_options
  }
  provider :developer unless Rails.env.production?
  provider :lti, :oauth_credentials => { ENV["LTI_CONSUMER_KEY"] => ENV["LTI_CONSUMER_SECRET"] }
  provider :kerberos, uid_field: :username, fields: [ :username, :password ]
end
