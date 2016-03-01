class SecureToken < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :target, polymorphic: true
  before_create :cache_encrypted_key, :cache_uuid, :set_expires_at
  attr_reader :random_secret_key

  def random_secret_key
    # generates a 254-character URL-safe secret key
    @random_secret_key ||= SecureRandom.urlsafe_base64(190)
  end

  # double-check to make sure that the authentication process is correct here
  def authenticates_with?(secret_key)
    # in order to check the give
    secret_key == SCrypt::Password.new(encrypted_key)
  end

  def secret_url
    secure_tokens_submissions_exports_url(target_uuid: uuid, secret_key: random_secret_key)
  end

  def has_valid_target_of_class?(required_class)
    target and target.class == required_class.to_s
  end

  protected

  def set_expires_at
    self[:expires_at] = Time.zone.now + 7.days
  end

  def cache_encrypted_key
    self[:encrypted_key] = SCrypt::Password.create(random_secret_key, scrypt_options)
  end

  def cache_uuid
    self[:uuid] = SecureRandom.uuid
  end

  def scrypt_options
    # let's use 512 bit security here becaues the only real loss is speed, and
    # since we'd prefer that this interaction take as long as it needs to in
    # order to deter brute force attacks, the maximum 512-bit hash here suits
    # our needs very well

    { key_len: 512 }
  end
end
