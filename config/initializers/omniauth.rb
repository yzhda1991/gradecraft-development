Rails.application.config.middleware.use OmniAuth::Builder do
  provider :canvas, ENV["CANVAS_CLIENT_ID"], ENV["CANVAS_CLIENT_SECRET"],
    setup: lambda { |env|
      env["omniauth.strategy"].options[:client_options].site =
        "#{ENV["CANVAS_BASE_URL"]}/login/canvas"
  }
  provider :developer unless Rails.env.production?
  provider :lti, :oauth_credentials => { ENV["LTI_CONSUMER_KEY"] => ENV["LTI_CONSUMER_SECRET"] }
  provider :kerberos, uid_field: :username, fields: [ :username, :password ]
end
