class SecureTokenAuthenticator
  def initialize(options={})
    @secure_token_uuid = options[:secure_token_uuid]
    @target_class = options[:target_class]
    @secret_key = options[:secret_key]
  end
  attr_reader :secure_token_uuid, :target_class, :secret_key

  def authenticates?
    uuid_format_valid? &&
    secure_key_format_valid? &&
    secure_token &&
    secure_token.authenticates_with?(secret_key)
  end

  def secure_token
    @secure_token ||= SecureToken.where(
      uuid: secure_token_uuid,
      target_type: target_class
    ).first
  end

  def uuid_format_valid?
    if secure_token_uuid.match REGEX["UUID"]
      true
    else
      # This should only occur is somebody is attempting to crack a key by
      # searching for random uuid values. By waiting for a second here we
      # drastically hinder attacks by slowing down the rate at which they can
      # be made but we do so without sacrificing system resources.
      sleep 3
      false
    end
  end

  def secure_key_format_valid?
    if secret_key.match REGEX["190_BIT_SECRET_KEY"]
      true
    else
      # This should only occur is somebody is attempting to crack a key by
      # searching for random uuid values. By waiting for a second here we
      # drastically hinder attacks by slowing down the rate at which they can
      # be made but we do so without sacrificing system resources.
      sleep 3
      false
    end
  end
end
