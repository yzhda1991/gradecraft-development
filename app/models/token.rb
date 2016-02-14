class Token < ActiveRecord::Base
  require 'secure_random'

  before_create :cache_secure_key
  attr_reader :naked_key

  def naked_key
    @naked_key ||= SecureRandom.base64(255)
  end

  def cache_secure_key
    self[:hashed_key] = SCrypt::Password.create naked_key, scrypt_options
  end

  protected

  def scrypt_options
    # bogart system resources on key hashing to deter brute force attacks
    {
      key_len: 512, # 512 bit security
      max_time: 1000, # max one second computation
      max_mem: 5 # use 5mb memory
    }
  end
end
