require_relative "secure_token_validator/regex"

class SecureTokenValidator < ActiveModel::Validator
  attr_accessor :record

  def validate(record)
    self.record = record
    validate_uuid_format
  end

  def validate_uuid_format
    return if record.uuid =~ Regex.uuid
    record.errors[:uuid] << "UUID format is not valid."
  end
end
