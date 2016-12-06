require_relative "../../app/proctors/submission_proctor.rb"

describe SubmissionProctor do
  subject { described_class.new submission }
  let(:submission) { double(:submission, link: nil, text_comment: nil, submission_files: []) }

  describe "#viewable" do
    it "returns true if the submission is not a draft" do
      allow(submission).to receive(:draft?).and_return false
      expect(subject.viewable?).to be true
    end

    it "returns false if the submission is a draft" do
      allow(submission).to receive(:draft?).and_return true
      expect(subject.viewable?).to be false
    end
  end

  describe "#viewable_submission" do
    it "returns nil if the submission is not viewable" do
      allow(subject).to receive(:viewable?).and_return(false)
      expect(subject.viewable_submission).to be_nil
    end

    it "returns the submission if the submission is viewable" do
      allow(subject).to receive(:viewable?).and_return(true)
      expect(subject.viewable_submission).to eq(submission)
    end
  end
end
