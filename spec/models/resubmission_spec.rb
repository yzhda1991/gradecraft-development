require "active_record_spec_helper"

describe Resubmission do
  let(:grade) do
    create :grade, status: "Released", submission: submission,
      assignment: submission.assignment
  end
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
    describe "it pairs up the grade revision with the submission revision" do
      before { submission.update_attributes link: "http://example.org" }

      context "with a submission change and no grade" do
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

      context "with several submission changes and two grades changes" do
        before do
          grade.update_attributes raw_score: 1234
          submission.update_attributes link: "http://google.com"
          grade.update_attributes raw_score: 5678
        end

        it "returns two resubmissions for the each grade change" do
          results = described_class.find_for_submission(submission)

          expect(results.length).to eq 2
          expect(results.first.submission_revision.reify.link).to eq nil
          expect(results.first.grade_revision.reify.raw_score).to eq nil
          expect(results.last.submission_revision.reify.link).to eq "http://example.org"
          expect(results.last.grade_revision.reify.raw_score).to eq 1234
        end
      end

      context "with a grade that is updated for other reasons than the score" do
        before { grade.update_attributes feedback: "You rock!" }

        it "returns no resubmissions" do
          expect(described_class.find_for_submission(submission)).to be_empty
        end
      end

      context "with a grade that is not visible to the student" do
        before { grade.update_attributes status: nil, raw_score: 1234 }

        it "returns no resubmissions" do
          expect(described_class.find_for_submission(submission)).to be_empty
        end
      end
    end
  end

  describe ".future_resubmission?" do
    it "returns false if the grade is not created" do
      expect(described_class.future_resubmission?(submission)).to eq false
    end

    it "returns true if the grade has already been assigned" do
      grade.touch
      expect(described_class.future_resubmission?(submission)).to eq true
    end

    it "returns false if the grade is not visible to the student" do
      grade.update_attributes status: nil
      expect(described_class.future_resubmission?(submission)).to eq false
    end
  end
end
