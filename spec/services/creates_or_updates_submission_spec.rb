describe Services::CreatesOrUpdatesSubmission do
  let(:assignment) { create :assignment }
  let(:submission) { create :submission }

  describe ".creates_or_updates_submission" do
    it "updates the resubmission flag" do
      expect(Services::Actions::UpdateSubmissionParams).to receive(:execute).and_call_original
      described_class.creates_or_updates_submission assignment, submission
    end

    it "updates the existing submission" do
      expect(Services::Actions::UpdateSubmissionParams).to receive(:execute).and_call_original
      described_class.creates_or_updates_submission assignment, submission
    end
  end
end
