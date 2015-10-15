# require 'syslogger'

GradeCraft::Application.configure do
  config.action_controller.perform_caching = false
  config.action_dispatch.best_standards_support = :builtin
  config.asset_host = "http://localhost:5000"

  config.action_mailer.default_url_options = { :host => 'localhost:1080' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => 'localhost',
    :port => 1025,
  }
  config.action_mailer.perform_deliveries = true

  config.action_mailer.raise_delivery_errors = true
  config.active_support.deprecation = :log
  config.assets.compress = false
  config.assets.debug = true
  config.cache_classes = false
  config.cache_store = :memory_store
  config.consider_all_requests_local = true
  config.eager_load = false
  config.log_level = :debug
  config.session_store :cookie_store, key: '_gradecraft_session'
  config.active_record.mass_assignment_sanitizer = :strict
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
  end
end

CarrierWave.configure do |config|
  config.storage = :file
end


# Papertrail http configuration
# config.logger = RemoteSyslogLogger.new('logs3.papertrailapp.com', 36742, :program => "rails-#{Rails.env}-#{ENV['LOG_NAME']}")
#
# Loggly http configuration
#config.logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/rails/", :threaded => true)
#
# Loggly TCP/UDP configuration, needs testing
#
# config.logger = Syslogger.new("GradeCraft", Syslog::LOG_PID, Syslog::LOG_LOCAL0)
# config.lograge.enabled = true
# config.lograge.formatter = Lograge::Formatters::Json.new
