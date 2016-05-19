require_relative "conditions/submission_file_conditions"

class SubmissionFileProctor
  attr_reader :submission_file

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable_by?(user)
    conditions = proctor_conditions.for(:downloadable)
    conditions.satisfied_by?(user)
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
