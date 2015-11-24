class InternalEmailValidator < ActiveModel::EachValidator
  attr_reader :format

  def initialize(options)
    super
    @format = options[:with]
  end

  def validate_each(record, attribute, value)
    if record.internal && !(record.email =~ format)
      record.errors[attribute] << "must be a University of Michigan email"
    end
  end
end
