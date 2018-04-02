module Services
  module Actions
    class UpdateSubmissionParams
      extend LightService::Action

      expects :assignment, :submission

      executed do |context|
        assignment = context[:assignment]
        submission = context[:submission]

        context.fail_with_rollback!("The submission is invalid and cannot be saved") \
          unless submission.save!

      end
    end
  end
end
