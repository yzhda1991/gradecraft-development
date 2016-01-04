class Resubmission
  attr_reader :grade_revision, :submission, :submission_revision

  def initialize(attributes={})
    attributes.each do |name, value|
      instance_variable_set "@#{name}", value if respond_to?(name)
    end
  end

  def self.find_for_submission(submission)
    resubmissions = []
    grade = submission.grade
    if grade.present?
      submission.versions.where(event: :update).each do |submission_revision|
        grade_revision = grade.versions
          .where(event: :update)
          .where("created_at >= :created_at", created_at: submission_revision.created_at)
          .last
        if grade_revision.present?
          resubmissions << Resubmission.new(submission: submission,
                                            grade_revision: grade_revision,
                                            submission_revision: submission_revision)
        end
      end
    end
    resubmissions
  end
end
