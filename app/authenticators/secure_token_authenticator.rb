class SecureTokenAuthenticator
  def initialize(options={})
    @options = default_options.merge options
    @slowdown_duration = @options[:slowdown_duration]
    required_options.each {|option| send "#{option}=", @options[option] }
  end

  attr_accessor :secure_token_uuid, :target_class, :target_id, :secret_key,
    :slowdown_duration

  # we should probably add a separate workflow here for just telling the user
  # if the secure token expired so they know that this is happening instead of
  #
  def authenticates?
    required_options_present? &&
    uuid_format_valid? &&
    secure_key_format_valid? &&
    secure_token &&
    !secure_token.expired? &&
    secure_token.authenticates_with?(secret_key)
  end

  def valid_token_expired?
    return unless secure_token
    secure_token.expired?
  end

  def secure_token
    @secure_token ||= SecureToken
      .find_by(
        uuid: secure_token_uuid,
        target_type: target_class,
        target_id: target_id
      )
  end

  def required_options
    [ :secure_token_uuid, :secret_key, :target_class, :target_id ]
  end

  def required_options_present?
    required_options.all? {|option| send(option).present? }
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

  def default_options
    { slowdown_duration: 1 }.freeze
  end
end
