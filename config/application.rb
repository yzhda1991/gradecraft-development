require_relative 'boot'

require 'rails/all'
require "csv"
require "sanitize"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

# Uncomment the following line to debug deprecations in gems
# ActiveSupport::Deprecation.debug = true

Bundler.require(*Rails.groups)

module GradeCraft
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/models/abilities)

    config.assets.precompile += %w(.svg .eot .otf .woff .ttf)
    config.filter_parameters += [:password]

    config.active_job.queue_adapter = :resque

    config.i18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]

    # Leave some pre-Rails 5.0 defaults as they were since they introduce breaking changes,
    # for now..
    config.active_record.belongs_to_required_by_default = false
    config.action_controller.forgery_protection_origin_check = false
    config.halt_callback_chains_on_return_false = true

    config.i18n.default_locale = :en
    config.angular_templates.ignore_prefix  = %w(angular/templates/)
    config.generators do |g|
      g.orm :active_record
      g.stylesheets :false
      g.template_engine :haml
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end
  end
end
