require_relative "submission_file_proctor/submission_file_condition_set"

class SubmissionFileProctor
  attr_reader :submission_file

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable_by?(user)
    proctor_conditions.for(:downloadable).satisfied_by? user
  end

  def proctor_conditions
    @proctor_conditions ||= Proctors::SubmissionFileConditionSet.new proctor: self
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
