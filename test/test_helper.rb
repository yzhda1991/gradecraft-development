ENV["RAILS_ENV"] ||= 'development'
require File.expand_path("../../config/environment", __FILE__)

# ResqueSpec libraries
require 'resque_spec/scheduler' # allow resque spec to test scheduled jobs

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("app/workers/**/*.rb")].each { |f| require f }
