module Services
  module Actions
    class UpdatesResubmissionFlag
      extend LightService::Action

      expects :assignment, :submission

      executed do |context|
        assignment = context[:assignment]
        submission = context[:submission]
        submission.resubmission = true if find_individual_grade(assignment, submission) || find_group_grade(assignment, submission)
        submission.save
      end

      private

      def self.find_individual_grade(assignment, submission)
        if assignment.nil? == false && submission.student_id.nil? == false
          return true if !Grade.where(assignment_id: assignment.id, student_id: submission.student_id).student_visible.empty?
        end
        return false
      end

      def self.find_group_grade(assignment, submission)
        if assignment.nil? == false && submission.group.nil? == false
          return true if !Grade.for_group(assignment, submission.group).student_visible.empty?
        end
        return false
      end

    end
  end
end
