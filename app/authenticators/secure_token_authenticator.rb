class SecureTokenAuthenticator
  def initialize(options={})
    @secure_token_uuid = options[:secure_token_uuid]
    @target_class = options[:target_class].to_s rescue ""
    @secret_key = options[:secret_key]
  end
  attr_reader :secure_token_uuid, :target_class, :secret_key

  def authenticates?
    options_valid? and secure_token and valid_target_class? and secure_token_authenticated?
  end

  protected

  def options_valid?
    secure_token_uuid.present? and target_class.present? and secret_key.present?
  end

  def secure_token_found?
    @secure_token ||= SecureToken.find_by_uuid secure_token_uuid
  end

  def valid_target_class?
    @secure_token.has_valid_target_of_class?(target_class)
  end

  def secure_token_authenticated?
    @secure_token.authenticates_with?(secret_key)
  end
end
