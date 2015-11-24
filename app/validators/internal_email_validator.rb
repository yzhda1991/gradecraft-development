class InternalEmailValidator < ActiveModel::EachValidator
  attr_reader :format, :name

  def initialize(options)
    super
    @format = options[:format]
    @name = options[:name] || "internal"
  end

  def validate_each(record, attribute, value)
    if record.internal && !(record.email =~ format)
      record.errors[attribute] << "must be a #{name} email"
    end
  end
end
