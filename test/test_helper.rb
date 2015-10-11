ENV["RAILS_ENV"] ||= 'development'
require File.expand_path("../../config/environment", __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("app/workers/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("app/performers/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }
