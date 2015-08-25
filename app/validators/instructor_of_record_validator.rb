class InstructorOfRecordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !record.staff? && value
      role_name = record.role.blank? ? "anyone" : record.role.pluralize
      record.errors[attribute] << "is not valid for #{role_name}"
    end
  end
end
