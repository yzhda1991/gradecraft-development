require "spec_helper"
require "./app/presenters/new_submission_presenter"

describe NewSubmissionPresenter do
  describe "#submission" do
    let(:assignment) { double(:assignment) }

    before { allow(subject).to receive(:assignment).and_return assignment }

    it "returns a new submission from the assignment" do
      submission = double(:submission)
      submissions = double(:active_record_relation, new: submission)
      allow(assignment).to receive(:submissions).and_return submissions
      expect(subject.submission).to eq submission
    end
  end

  describe "#student" do
    let(:student) { double(:user) }
    let(:view_context) { double(:view_context, current_student: student) }
    subject { described_class.new view_context: view_context }

    it "returns the current student from the view context" do
      expect(subject.student).to eq student
    end
  end
end
