class SecureTokenAuthenticator
  def initialize(options={})
    @secure_token_uuid = options[:secure_token_uuid]
    @target_class = options[:target_class]
    @secret_key = options[:secret_key]
  end
  attr_reader :secure_token_uuid, :target_class, :secret_key

  def authenticates?
    options_present? &&
      secure_token_found? &&
      target_exists? &&
      secure_token_authenticated?
  end

  def options_present?
    required_options.all?(&:present?)
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

  def required_options
    [ secure_token_uuid, target_class, secret_key ]
  end
end
