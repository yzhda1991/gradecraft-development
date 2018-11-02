Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.

  config.cache_classes = false
  config.cache_store = :memory_store

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  # config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  config.action_mailer.delivery_method = :smtp

  # NOTE: to test emails locally
  # 1. gem install mailcatcher
  # 2. run 'mailcatcher' in terminal
  # 3. visit http://127.0.0.1:1080/
  # 4. set perform_deliveries to true
  config.action_mailer.default_url_options = { host: "localhost:5000" }
  config.action_mailer.smtp_settings = { address: '127.0.0.1', port: 1025 }
  config.action_mailer.perform_deliveries = true

  # NOTE: to send emails via Gmail's SMTP server
  # 1. IMPORTANT! Set ENV["MAIL_INTERCEPTOR_RECIPIENT"]
  # 2. Set ENV["GMAIL_SMTP_USERNAME"], ENV["GMAIL_SMTP_PASSWORD"] to match Gmail
  #   login credentials; e.g. blah@gmail.com, password123
  # 3. Update mail_interceptor.rb to register the interceptor for
  #   Rails.env.development
  # config.action_mailer.default_url_options = { host: "localhost:5000" }
  # config.action_mailer.smtp_settings = {
  #   address:              "smtp.gmail.com",
  #   port:                 587,
  #   domain:               "localhost:5000",
  #   user_name:            ENV["GMAIL_SMTP_USERNAME"],
  #   password:             ENV["GMAIL_SMTP_PASSWORD"],
  #   authentication:       "plain",
  #   enable_starttls_auto: true
  # }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_level = :debug

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.asset_host = ENV["GC_ASSET_HOST"] unless ENV["GC_ASSET_HOST"].nil?
  config.assets.compress = false

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_dispatch.best_standards_support = :builtin

  config.session_store :cookie_store, key: "_gradecraft_session"

  # Uncomment Bullet config to evaluate N+1 queries
  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = false
  #   Bullet.bullet_logger = true # log to the Bullet log file (Rails.root/log/bullet.log)
  #   Bullet.console = true
  #   # Bullet.rails_logger = false
  #   # Bullet.rollbar = false
  #   # Bullet.add_footer = true
  #   # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
  #   # Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
  #   # Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
  # end
end

require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  config.storage = :fog
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end
