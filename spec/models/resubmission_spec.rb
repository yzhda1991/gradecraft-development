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

  describe ".find_for_submission", versioning: true do
    let(:grade) { create :grade, submission: submission, assignment: submission.assignment }

    describe "it pairs up the grade revision with the submission revision" do
      before { submission.update_attributes link: "http://example.org" }

      context "with a submission change and no grades" do
        it "returns no resubmissions" do
          expect(described_class.find_for_submission(submission)).to be_empty
        end
      end

      context "with a submission change and one grade change" do
        before { grade.update_attributes raw_score: 1234 }

        it "returns one resubmission" do
          results = described_class.find_for_submission(submission)

          expect(results.length).to eq 1
          expect(results.first.submission).to eq submission
          expect(results.first.submission_revision.event).to eq "update"
          expect(results.first.submission_revision.reify.link).to eq nil
          expect(results.first.grade_revision.event).to eq "update"
          expect(results.first.grade_revision.reify.raw_score).to eq nil
        end
      end

      context "with several submission changes and one grade change" do
        before do
          submission.update_attributes link: "http://google.com"
          grade.update_attributes raw_score: 1234
        end

        it "returns one resubmission for the last submission change" do
          results = described_class.find_for_submission(submission)

          expect(results.length).to eq 1
          expect(results.first.submission_revision.reify.link).to eq "http://example.org"
        end
      end

      xit "with several submission changes and several grades"
      xit "with a grade that is not visible to the student"
      xit "with an assignment that no longer accepts submissions"
    end
  end
end
