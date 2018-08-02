require "light-service"
require_relative "submissions/removes_text_comment_draft"

module Services
  class DeletesSubmissionDraftContent
    extend LightService::Organizer

    def self.call(submission)
      with(submission: submission)
        .reduce(
          Actions::RemovesTextCommentDraft
        )
    end
  end
end
