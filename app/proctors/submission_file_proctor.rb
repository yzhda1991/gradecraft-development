class SubmissionFileProctor
  include Proctors::SubmissionFile::Downloadable

  attr_reader :submission_file, :user, :course, :group

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable?(user:, course: nil)
    @course = course || submission.course
    @user = user

    Proctors::SubmissionFile::Downloadable.
    define_conditions
    conditions_satisfied?
  end

  def submission
    @submission ||= submission_file.submission
  end

  def assignment
    @assignment ||= submission.assignment
  end
end
