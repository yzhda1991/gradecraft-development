class Resubmission
  attr_reader :grade_revision, :submission, :submission_revision

  def initialize(attributes={})
    attributes.each do |name, value|
      instance_variable_set "@#{name}", value if respond_to?(name)
    end
  end

  class << self
    def find_for_submission(submission)
      resubmissions = []
      grade = submission.grade
      if include_grade?(grade)
        grade.versions.updates.each do |grade_revision|
          if include_grade_revision? grade_revision
            submission_revision = submission_revision_for_grade submission, grade_revision
            if submission_revision.present?
              resubmissions << Resubmission.new(submission: submission,
                                                grade_revision: grade_revision,
                                                submission_revision: submission_revision)
            end
          end
        end
      end
      resubmissions
    end

    def future_resubmission?(submission)
      grade = submission.grade
      include_grade?(grade)
    end

    private

    def include_grade?(grade)
      grade.present? && grade.is_student_visible?
    end

    def include_grade_revision?(grade_revision)
      grade_revision.changeset.has_key?("raw_score")
    end

    def submission_revision_for_grade(submission, grade_revision)
      submission.versions.updates.preceding(grade_revision.created_at, true).last
    end
  end
end
