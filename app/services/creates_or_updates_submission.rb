require "light-service"
require_relative "creates_or_updates_submission/updates_submission_params"
require_relative "creates_or_updates_submission/updates_resubmission_flag"

module Services
  class CreatesOrUpdatesSubmission
    extend LightService::Organizer

    def self.creates_or_updates_submission(assignment, submission)
      with(assignment: assignment, submission: submission)
        .reduce(
          Actions::UpdateSubmissionParams,
          Actions::UpdatesResubmissionFlag
        )
    end
  end
end
