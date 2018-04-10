module Services
  module Actions
    class UpdatesResubmissionFlag
      extend LightService::Action

      expects :assignment, :submission

      executed do |context|
        assignment = context[:assignment]
        submission = context[:submission]
        submission.update(resubmission: true) if current_grade_exists?(assignment, submission)
      end

      private

      def self.current_grade_exists?(assignment, submission)
        if assignment.is_individual?
          Grade.where(assignment_id: assignment.id, student_id: submission.student_id).student_visible.present?
        else
          Grade.for_group(assignment, submission.group).student_visible.present?
        end
      end

    end
  end
end
