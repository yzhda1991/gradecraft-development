ENV['RAILS_ENV'] ||= 'test'
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'active_record'
require 'acts_as_list'
require 'canable'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'carrierwave_backgrounder'
require 'backgrounder/orm/activemodel'
require 'factory_girl'
require 'faker'
require 'protected_attributes'
require 'sanitize'
require 'sorcery'
require 'yaml'

::ActiveRecord::Base.raise_in_transactional_callbacks = true
::ActiveRecord::Base.extend CarrierWave::Backgrounder::ORM::ActiveModel

::Sorcery::Controller::Config.submodules = [:user_activation]
::Sorcery::Controller::Config.user_config do |user|
  user.activation_mailer_disabled = true
  user.user_activation_mailer = nil
end

require './lib/display_helpers'
require './lib/s3_file'
Dir['./app/validators/*.rb'].each { |f| require f }
Dir['./app/uploaders/*.rb'].each { |f| require f }
Dir['./app/models/*.rb'].each { |f| require f }

def fixture_file(file, filetype='image/jpg')
  require 'rack/test'
  Rack::Test::UploadedFile.new File.join('spec', 'fixtures', 'files', file), filetype
end

connection_info = YAML.load_file("config/database.yml")["test"]
ActiveRecord::Base.establish_connection(connection_info)

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

FactoryGirl.factories.clear
FactoryGirl.find_definitions

RSpec.configure do |config|
  # Base Spec Helper
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec
  config.order = "random"
  config.tty = true
  # End Base Spec Helper

  config.include FactoryGirl::Syntax::Methods

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
    raise ActiveRecord::Rollback
    end
  end
end
