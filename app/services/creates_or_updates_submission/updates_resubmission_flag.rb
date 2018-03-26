module Services
  module Actions
    class UpdatesResubmissionFlag
      extend LightService::Action

      expects :assignment, :submission

      executed do |context|
        assignment = context[:assignment]
        submission = context[:submission]
        submission.resubmission = true if find_grade(assignment, submission)
        submission.save

      end

      private

      def self.find_grade(assignment, submission)
        return true if Grade.where(assignment_id: assignment.id, student_id: submission.student_id)
        return false
      end

    end
  end
end
