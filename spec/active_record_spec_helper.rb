require "base_spec_helper"
require "active_record"
require "active_support/core_ext"
require "acts_as_list"
require "canable"
require "carrierwave"
require "carrierwave/orm/activerecord"
require "factory_girl"
require "faker"
require "protected_attributes"
require "sorcery"
require "yaml"
require "./lib/s3_file"
require_relative "support/sorcery_stubbing"

# stub out the process_in_background for carrierwave_backgrounder
module CarrierWave
  module Backgrounder
    module Delay; end
  end
end
class ActiveRecord::Base
  def self.process_in_background(_); end
end

SorceryStubbing.sorcery_reset [:user_activation], user_activation_mailer: SorceryStubbing::TestUserMailer

Dir["./app/uploaders/*.rb"].each { |f| require f }
Dir["./app/validators/*.rb"].each { |f| require f }
Dir["./app/models/concerns/*.rb"].each { |f| require f }
Dir["./app/models/*.rb"].reject{|m| m =~ /metric|tier/ }.each { |f| require f }

connection_info = YAML.load_file("config/database.yml")["test"]
ActiveRecord::Base.establish_connection(connection_info)

# supress the warning that is generated from CarrierWave because it uses
# after_commit/after_save callbacks
ActiveRecord::Base.raise_in_transactional_callbacks = true

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.factories.clear
    FactoryGirl.find_definitions
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
