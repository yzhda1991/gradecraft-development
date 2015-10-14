GradeCraft::Application.configure do
  config.action_controller.perform_caching = false
  config.action_dispatch.best_standards_support = :builtin
  config.asset_host = "http://localhost:5000"
  config.action_mailer.default_url_options = { :host => 'localhost:5000' }
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.active_support.deprecation = :log
  config.assets.compress = false
  config.assets.debug = true
  config.cache_classes = false
  # config.logger = RemoteSyslogLogger.new('logs3.papertrailapp.com', 36742, :program => "rails-#{Rails.env}-#{ENV['LOG_NAME']}")
  #config.logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/rails/", :threaded => true)
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
