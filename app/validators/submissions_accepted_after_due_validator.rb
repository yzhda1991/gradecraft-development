class SubmissionsAcceptedAfterDueValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :base, "Submission accept date must be after due date." \
    if (record.due_at? && record.accepts_submissions_until?) &&
      (record.accepts_submissions_until < record.due_at)
  end
end
