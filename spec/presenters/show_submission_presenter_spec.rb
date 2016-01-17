require "active_support/inflector"
require "./app/presenters/show_submission_presenter"
require_relative "showing_a_submission_spec"

describe ShowSubmissionPresenter do
  let(:assignment) { double(:assignment, point_total: 12000) }
  let(:student) { double(:user, first_name: "Jimmy") }
  let(:submission) { double(:submission, student: student) }

  it_behaves_like "showing a submission"

  describe "#title" do
    let(:view_context) { double(:view_context, points: "12,000") }

    before do
      allow(subject).to receive(:assignment).and_return assignment
      allow(subject).to receive_messages submission: submission, view_context: view_context
    end

    it "includes the individual's name for a student" do
      allow(assignment).to receive_messages name: "New Assignment", is_individual?: true
      expect(subject.title).to eq "Jimmy's New Assignment Submission (12,000 points)"
    end

    it "includes the groups's name for a group" do
      group = double(:group, name: "My group")
      allow(subject).to receive(:group).and_return group
      allow(assignment).to receive_messages name: "New Assignment", is_individual?: false, has_groups?: true
      expect(subject.title).to eq "My group's New Assignment Submission (12,000 points)"
    end
  end

  describe "#submission_grade_history" do
    let(:grade) { double(:grade) }

    it "returns the combined history for the submission and grade for the student" do
      submission_version = double(:version)
      grade_version = double(:version)
      allow(subject).to receive(:assignment).and_return assignment
      allow(subject).to receive(:submission).and_return submission
      allow(subject).to receive(:grade).and_return grade
      allow(submission).to receive(:historical_merge).with(grade)
        .and_return [submission_version, grade_version]

      expect(subject.submission_grade_history).to eq [submission_version, grade_version]
    end
  end
end
