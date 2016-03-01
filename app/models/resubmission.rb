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
        submission.versions.updates.each do |submission_revision|
          grade_revision = grade_revision_for_submission grade, submission_revision
          if include_grade_revision?(grade_revision)
            resubmissions << Resubmission.new(submission: submission,
                                              grade_revision: grade_revision,
                                              submission_revision: submission_revision)
          end
        end
      end
      resubmissions
    end

    private

    def grade_revision_for_submission(grade, submission_revision)
      grade.versions.preceding(submission_revision.created_at, true).last
    end

    def include_grade?(grade)
      grade.present? && grade.is_student_visible?
    end

    def include_grade_revision?(grade_revision)
      grade_revision.present? &&
        (grade_revision.changeset.key?("raw_score") ||
         grade_revision.event == "create")
    end
  end
end
