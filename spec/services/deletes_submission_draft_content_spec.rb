require "active_record_spec_helper"
require "./app/services/deletes_submission_draft_content"

describe Services::DeletesSubmissionDraftContent do
  let(:submission) { build(:submission, text_comment_draft: "Dear professor, ") }

  describe ".for" do
    it "removes the text comment draft" do
      expect(Services::Actions::RemovesTextCommentDraft).to receive(:execute).and_call_original
      described_class.for submission
    end
  end
end
