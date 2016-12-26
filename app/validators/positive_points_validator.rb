class PositivePointsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add :base, "Point total must be a positive number" if attribute.present? && value < 1
  end
end
