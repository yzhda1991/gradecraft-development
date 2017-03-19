class LessThanAssignmentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add :base, "The full points for the assignment must be less than the cap for the whole assignment type." if (record.full_points? && record.assignment_type.present? && record.assignment_type.max_points?) && (record.full_points < record.assignment_type.max_points)
  end
end
