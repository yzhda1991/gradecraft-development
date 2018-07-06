describe Services::DeletesSubmissionDraftContent do
  let(:submission) { build(:submission, text_comment_draft: "Dear professor, ") }

  describe ".call" do
    it "removes the text comment draft" do
      expect(Services::Actions::RemovesTextCommentDraft).to receive(:execute).and_call_original
      described_class.call submission
    end
  end
end
