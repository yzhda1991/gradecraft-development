require_relative "../../app/proctors/submission_proctor.rb"

describe SubmissionProctor do
  subject { described_class.new submission }
  let(:submission) { double(:submission, link: nil, text_comment: nil, submission_files: []) }

  describe "#viewable" do
    it "returns true when a link exists on the submission" do
      allow(submission).to receive(:link).and_return(true)
      expect(subject.viewable?).to eq(true)
    end

    it "returns true when a text_comment exists on the submission" do
      allow(submission).to receive(:text_comment).and_return(true)
      expect(subject.viewable?).to eq(true)
    end

    it "return true when there are submission files on the submission" do
      allow(submission).to receive(:submission_files).and_return(["file1", "file2"])
      expect(subject.viewable?).to eq(true)
    end

    it "returns false when there are neither links, nor text comments, nor submission files" do
      expect(subject.viewable?).to eq(false)
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
