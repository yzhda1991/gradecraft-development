class PositivePointsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if attribute.present? && value < 1
      record.errors.add :base, "Point total must be a positive number"
    end
  end
end
