class SecureTokenAuthenticator
  def initialize(options={})
    @secure_token_uuid = options[:secure_token_uuid]
    @target_class = options[:target_class]
    @secret_key = options[:secret_key]
    @slowdown_duration = 1
  end
  attr_reader :secure_token_uuid, :target_class, :secret_key, :slowdown_duration

  # we should probably add a separate workflow here for just telling the user
  # if the secure token expired so they know that this is happening instead of
  #
  def authenticates?
    uuid_format_valid? &&
    secure_key_format_valid? &&
    secure_token &&
    !secure_token.expired? &&
    secure_token.authenticates_with?(secret_key)
  end

  def valid_token_expired?
    if secure_token
      secure_token.expired?
    end
  end

  def secure_token
    @secure_token ||= SecureToken
      .find_by(
        uuid: secure_token_uuid,
        target_type: target_class
      )
  end

  def uuid_format_valid?
    if secure_token_uuid.match REGEX["UUID"]
      true
    else
      # This should only occur if somebody is attempting to crack a key by
      # searching for random uuid values. By sleeping for a moment here we
      # drastically hinder attacks by slowing down the rate at which they can
      # be made but we do so without sacrificing system resources.
      sleep slowdown_duration
      false
    end
  end

  def secure_key_format_valid?
    if secret_key.match REGEX["190_BIT_SECRET_KEY"]
      true
    else
      # This should only occur if somebody is attempting to crack a key by
      # searching for random uuid values. By sleeping for a moment here we
      # drastically hinder attacks by slowing down the rate at which they can
      # be made but we do so without sacrificing system resources.
      sleep slowdown_duration
      false
    end
  end
end
