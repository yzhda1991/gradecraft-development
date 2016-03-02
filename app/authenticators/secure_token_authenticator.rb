class SecureTokenAuthenticator
  def initialize(options={})
    @secure_token_uuid = options[:secure_token_uuid]
    @target_class = options[:target_class]
    @secret_key = options[:secret_key]
  end
  attr_reader :secure_token_uuid, :target_class, :secret_key

  def authenticates?
    options_valid? && secure_token && target_exists? && secure_token_authenticated?
  end

  protected

  def options_valid?
    secure_token_uuid.present? && target_class.present? && secret_key.present?
  end

  def secure_token_found?
    @secure_token ||= SecureToken.find_by_uuid secure_token_uuid
  end

  def target_exists?
    @secure_token.has_target_of_class?(target_class)
  end

  def secure_token_authenticated?
    @secure_token.authenticates_with?(secret_key)
  end
end
