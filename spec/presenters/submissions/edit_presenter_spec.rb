require "active_record_spec_helper"
require "./app/presenters/submissions/edit_presenter"
require_relative "../../../app/presenters/submissions/grade_history"
require "./app/models/submission"

describe Submissions::EditPresenter do
  let(:assignment) { double(:assignment) }
  before { allow(subject).to receive(:assignment).and_return assignment }

  subject { described_class.new id: 1234 }

  before { allow(subject).to receive(:assignment).and_return assignment }

  describe "#submission" do
    context "properties[:submission] exists" do
      subject { described_class.new id: 1234, submission: "some-entity" }

      it "returns properties[:submission]" do
        expect(subject.submission).to eq "some-entity"
      end
    end

    context "properties[:submission] does not exist" do
      let(:submission) { create(:submission) }
      let(:result) { subject.submission }

      context "id exists and Submission.where returns a valid record" do
        before do
          allow(subject).to receive(:id) { submission.id }
          allow(Submission).to receive(:where) { [submission] }
        end

        it "finds the submission by id" do
          expect(Submission).to receive(:where).with id: submission.id
          result
        end

        it "caches the submission" do
          result
          expect(Submission).not_to receive(:where).with id: submission.id
          result
        end

        it "sets the submission to an ivar" do
          result
          expect(subject.instance_variable_get(:@submission)).to eq submission
        end
      end

      context "a non-existent id is passed to Submission.where" do
        it "rescues to nil" do
          allow(subject).to receive(:id) { 980_000 }
          expect(result).to eq nil
        end
      end

      context "a nil id is passed to Submission.where" do
        it "rescues to nil" do
          allow(subject).to receive(:id) { nil }
          expect(result).to eq nil
        end
      end
    end
  end

  describe "#student" do
    let(:submission) { double(:submission, student: student) }
    let(:student) { double(:user) }

    before { allow(subject).to receive(:submission).and_return submission }

    it "returns the student for the submission" do
      expect(subject.student).to eq student
    end
  end

  describe "#initialize" do
    it "allows a submission to be set" do
      submission = double(:submission)
      subject = described_class.new submission: submission
      expect(subject.submission).to eq submission
    end
  end
end
