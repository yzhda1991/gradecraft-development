require "./app/presenters/submissions/edit_presenter"
require_relative "showing_a_submission_spec"

describe Submissions::EditPresenter do
  let(:assignment) { double(:assignment) }
  before { allow(subject).to receive(:assignment).and_return assignment }

  describe "ported from shared examples" do
    let(:assignment) { double(:assignment) }
    let(:submission_id) { 123 }
    subject { described_class.new id: submission_id }

    before { allow(subject).to receive(:assignment).and_return assignment }

    describe "#submission" do
      it "returns the submission from the assignment based on the id" do
        submission = double(:submission)
        submissions = double(:active_record_relation)
        allow(submissions).to receive(:find).with(submission_id).and_return submission
        allow(assignment).to receive(:submissions).and_return submissions
        expect(subject.submission).to eq submission
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
