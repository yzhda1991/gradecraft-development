class SubmissionFileProctor
  attr_reader :submission_file, :course

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable?(user:)
    proctor_conditions.for(:downloadable).satisfied_by?(user)
  end

  def proctor_conditions
    @proctor_conditions ||= Proctors::SubmissionFileConditions.new(proctor: self)
  end

  def course
    @course ||= submission.course
  end

  def submission
    @submission ||= submission_file.submission
  end

  def assignment
    @assignment ||= submission.assignment
  end
end
