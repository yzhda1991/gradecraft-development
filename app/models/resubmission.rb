class Resubmission
  attr_reader :grade, :submission

  def initialize(attributes={})
    attributes.each do |name, value|
      instance_variable_set "@#{name}", value if respond_to?(name)
    end
  end

  def self.find_for_submission(submission)
    resubmissions = []
    grade = submission.grade
    if grade.present?
      grade.versions.where(event: :update).each do |grade|
        resubmissions << Resubmission.new(submission: submission, grade: grade)
      end
    end
    resubmissions
  end
end
