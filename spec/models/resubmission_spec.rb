require "active_record_spec_helper"

describe Resubmission do
  let(:submission) { create :submission }

  describe "#initialize" do
    it "initializes with attributes" do
      subject = described_class.new submission: submission
      expect(subject.submission).to eq submission
    end

    it "does not create an instance variable if there is no accessor" do
      subject = described_class.new blah: "blah"
      expect(subject.instance_variable_get("@blah")).to be_nil
    end
  end

  describe ".find_for_submission" do
    it "is empty if there are no grades for the submission" do
      expect(described_class.find_for_submission(submission)).to be_empty
    end

    context "with one grade revision", versioning: true do
      let(:grade) { create :grade, submission: submission, assignment: submission.assignment }

      before do
        grade.update_attributes raw_score: 1234
      end

      it "returns one resubmission" do
        results = described_class.find_for_submission(submission)

        expect(results.length).to eq 1
        expect(results.first.submission).to eq submission
        expect(results.first.grade.event).to eq "update"
        expect(results.first.grade.reify.raw_score).to eq nil
      end
    end
  end
end
