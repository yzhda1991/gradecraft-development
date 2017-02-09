class SubmissionProctor
  def initialize(submission)
    @submission = submission
  end

  # If the user is not considered staff, the submission should be viewable
  # Otherwise, it should only be visible if it is not a draft
  def viewable?(user)
    return @submission.belongs_to? user if user.is_student? @submission.course
    !@submission.unsubmitted?
  end

  def viewable_submission(user)
    return nil unless viewable? user
    @submission
  end

  def open_for_editing?(assignment)
    assignment.open? && resubmissions_allowed?(assignment)
  end

  private

  # If graded, the grade must be released and the assignment must allow resubmissions
  # otherwise, the assignment must allow resubmissions
  def resubmissions_allowed?(assignment)
    if @submission.grade.present?
      @submission.grade.graded_and_visible_by_student? && assignment.resubmissions_allowed?
    else
      assignment.resubmissions_allowed?
    end
  end
end
