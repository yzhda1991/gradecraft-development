class SubmissionAfterOpenValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add :base, "Submission accept date must be after open date." if (record.accepts_submissions_until? && record.open_at?) && (record.accepts_submissions_until < record.open_at)
  end
end
