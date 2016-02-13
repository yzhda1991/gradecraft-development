class Token < ActiveRecord::Base
  require 'bcrypt'
  require 'secure_random'

  before_create :generate_secure_keys

  attr_reader :naked_keys

  self.find_with_keys(key1,key2,key3)
  end

  def naked_keys
    @naked_keys ||= (1..3).collect { SecureRandom.base64(100) }
  end

  def hashed_keys
    @hashed_keys ||= naked_keys.collect do |naked_key|
      BCrypt::Password.create naked_key
    end
  end

  def generate_secure_keys
  end
end
