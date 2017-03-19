class SubmissionAfterDueValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add :base, "Submission accept date must be after due date." if (record.due_at? && record.accepts_submissions_until?) && (record.accepts_submissions_until < record.due_at)
  end
end
