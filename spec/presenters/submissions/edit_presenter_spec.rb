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

  describe "#title" do
    let(:user) { double(:user, is_student?: false) }
    let(:view_context) { double(:view_context, current_user: user) }
    before { allow(subject).to receive(:view_context).and_return view_context }

    it "contains the group name if the assignment has a group" do
      group = double(:group, name: "Cool kids")
      allow(assignment).to receive(:has_groups?).and_return true
      allow(subject).to receive(:group).and_return group
      expect(subject.title).to eq "Editing Cool kids's Submission"
    end

    it "contains the students name if the current user is staff" do
      student = double(:user, name: "Jimmy Page")
      submission = double(:submission, student: student)
      allow(subject).to receive(:submission).and_return submission
      allow(assignment).to receive(:has_groups?).and_return false
      expect(subject.title).to eq "Editing Jimmy Page's Submission"
    end

    it "contains the assignment name if the current user is a student" do
      allow(user).to receive(:is_student?).and_return true
      allow(assignment).to receive(:name).and_return "Big assignment"
      expect(subject.title).to eq "Editing My Submission for Big assignment"
    end
  end
end
