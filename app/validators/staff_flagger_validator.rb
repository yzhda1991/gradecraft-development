class StaffFlaggerValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.course.present? && value.present?
      flagger = value
      unless flagger.is_staff?(record.course)
        record.errors[attribute] << "must be a staff member"
      end
    end
  end
end
