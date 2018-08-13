class StudentLoggedValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :base, "Assignment cannot be self-logged if group-graded" \
      if record.student_logged? && record.has_groups?
  end
end
