require "active_support/inflector"
require "active_record_spec_helper"
require "./app/presenters/show_submission_presenter"
require_relative "showing_a_submission_spec"

describe ShowSubmissionPresenter do
  # build a new presenter with some default properties
  subject { described_class.new properties }

  let(:properties) do
    {
      id: submission.id,
      assignment_id: assignment.id,
      group_id: group.id,
      course: course
    }
  end

  let(:submission) { create(:submission, student: student, group: group, assignment: assignment) }
  let(:assignment) { create(:assignment, point_total: 12000, course: course, threshold_points: 13200, grade_scope: "Group") }
  let(:course) { create(:course, name: "Some Course") }
  let(:student) { create(:user, first_name: "Jimmy") }
  let(:group) { create(:group, name: "My group", course: course) }
  it "inherits from the Submission Presenter" do
    expect(described_class.superclass).to eq SubmissionPresenter
  end

  it "includes SubmissionGradeHistory" do
    expect(subject).to respond_to :submission_grade_filtered_history
  end

  describe "#individual_assignment?" do
    it "returns the output of assignment#is_individual?" do
      allow(subject.assignment).to receive(:is_individual?) { "stuff" }
      expect(subject.individual_assignment?).to eq "stuff"
    end
  end

  describe "#owner" do
    context "the submission is for an individual student assignment" do
      it "returns the student" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(subject.owner).to eq student
      end
    end

    context "the submission is for a group assignment" do
      it "returns the group" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(subject.owner).to eq group
      end
    end
  end

  describe "#owner_name" do
    context "the submission is for an individual student assignment" do
      it "returns the student's first name" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(subject.owner_name).to eq student.first_name
      end
    end

    context "the submission is for a group assignment" do
      it "returns the group name" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(subject.owner_name).to eq group.name
      end
    end
  end
end
