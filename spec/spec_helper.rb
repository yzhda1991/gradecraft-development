if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start

  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

# ResqueSpec libraries
require 'resque_spec/scheduler' # allow resque spec to test scheduled jobs

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/toolkits/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
# ActiveRecord::Migration.maintain_test_schema!

def clean_models
  User.destroy_all
  Course.destroy_all
  AssignmentType.destroy_all
  Assignment.destroy_all
end

RSpec.configure do |config|
  config.include FileHelpers
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      #FactoryGirl.lint
      FactoryGirl.factories.clear
      FactoryGirl.find_definitions
    ensure
      DatabaseCleaner.clean
    end
  end

  config.include FactoryGirl::Syntax::Methods

  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
  config.include GradeCraft::Matchers::Integration, type: :feature

  config.include BackgroundJobs
  config.tty = true

  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.infer_spec_type_from_file_location!

  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false # THIS IS DIFFERENT FROM THE BASE SPEC HELPER. TODO: GET ALIGNED
  end

  # Remove uploader files, see config/environments/test.rb
  config.after(:all) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
  end
end
