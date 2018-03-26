module Services
  module Actions
    class UpdateSubmissionParams
      extend LightService::Action

      expects :assignment, :submission

      executed do |context|
        assignment = context[:assignment]
        submission = context[:submission]

        submission.save!

      end
    end
  end
end
