class FileSizeValidator < ActiveModel::EachValidator
  def initialize(options)
    super
  end

  def validate_each(record, attribute, value)
  end
end
