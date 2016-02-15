class Token < ActiveRecord::Base
  require 'secure_random'

  before_create :cache_encrypted_key, :cache_token_id_hash
  attr_reader :naked_key

  def random_secret_key
    @secret_key ||= SecureRandom.base64(255)
  end

  def authenticates_with?(secret_key)
    encrypted_key == SCrypt::Password.create(secret_key, scrypt_options)
  end

  protected

  def cache_encrypted_key
    self[:encrypted_key] = SCrypt::Password.create(random_secret_key, scrypt_options)
  end

  def cache_token_id_hex
    self[:token_id_hex] = SecureRandom.hex(64)
  end

  def scrypt_options
    # bogart system resources on key hashing to deter brute force attacks
    {
      key_len: 512, # 512 bit security
      max_time: 1000, # max one second computation
      max_mem: 5 # use 5mb memory
    }
  end
end
