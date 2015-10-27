ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

# ResqueSpec libraries
require 'resque_spec/scheduler' # allow resque spec to test scheduled jobs

# try to load the mongoid config
# Mongoid.load!(Rails.root.join("/config/mongoid.yml"))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/toolkits/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
# ActiveRecord::Migration.maintain_test_schema!

# fixture file no longer works, this is a workaround
# here is an alternative solution that didn't work for me:
# http://stackoverflow.com/questions/9011425/fixture-file-upload-has-file-does-not-exist-error
def fixture_file(file, filetype='image/jpg')
  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', file), filetype)
end

def clean_models
  User.destroy_all
  Course.destroy_all
  AssignmentType.destroy_all
  Assignment.destroy_all
end

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
end
