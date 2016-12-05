class SubmissionProctor
  def initialize(submission)
    @submission = submission
  end

  # Viewable if the submission is not an autosaved draft
  # A submission is considered a draft if it has no link, text_comment,
  # or submission_files
  def viewable?
    @submission.link.present? || @submission.text_comment.present? ||
      !@submission.submission_files.empty?
  end

  def viewable_submission
    return nil unless viewable?
    @submission
  end
end
