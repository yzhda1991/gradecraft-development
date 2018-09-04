Rails.application.configure do
  config.action_controller.default_url_options = { :host => "staging.gradecraft.com" }
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
  config.asset_host = ENV["GC_ASSET_HOST"] || "https://staging.gradecraft.com"
  config.action_mailer.default_url_options = { :host => "staging.gradecraft.com" }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              "smtp.gmail.com",
    port:                 587,
    domain:               "staging.gradecraft.com",
    user_name:            ENV["GMAIL_SMTP_USERNAME"],
    password:             ENV["GMAIL_SMTP_PASSWORD"],
    authentication:       "plain",
    enable_starttls_auto: true
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :notify
  config.assets.compile = ["1", "yes", "true", "on"].include?(ENV["GC_ASSETS_COMPILE"] || "0" )
  config.assets.compress = true
  config.assets.css_compressor = :sass
  config.assets.digest = true
  config.assets.js_compressor = Uglifier.new(mangle: false)
  config.cache_classes = true
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'], expires_in: 1.day }
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.log_level = :debug
  config.public_file_server.enabled = ["1", "yes", "true", "on"].include?(ENV["GC_SERVE_STATIC_FILES"] || "0" )
  config.session_store :active_record_store, :expire_after => 60.minutes
end

require "carrierwave/storage/fog"

CarrierWave.configure do |config|
  config.storage = :fog
end
