require "active_support/inflector"
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

  let(:submission) { double(:submission, student: student, group: group, assignment: assignment, id: 200) }
  let(:assignment) { double(:assignment, point_total: 12000, course: course, threshold_points: 13200, grade_scope: "Group", id: 300) }
  let(:course) { double(:course, name: "Some Course").as_null_object }
  let(:student) { double(:user, first_name: "Jimmy", id: 500)}
  let(:group) { double(:group, name: "My group", course: course, id: 400) }

  before do
    allow(subject).to receive_messages(
      student: student,
      group: group
    )
  end

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

  describe "#grade" do
    let(:result) { subject.grade }

    let(:grades_double) { double(:grades) }

    before(:each) do
      allow(assignment).to receive(:grades) { grades_double }
      subject.instance_variable_set(:@grade, nil)
    end

    it "caches the grade" do
      result
      expect(grades_double).not_to receive(:find_by)
      result
    end

    context "the submission is for an individual student assignment" do
      it "finds the grade by student_id" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(grades_double).to receive(:find_by).with(student_id: student.id)
        result
      end
    end

    context "the submission is for a group assignment" do
      it "finds the grade by group_id" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(grades_double).to receive(:find_by).with(group_id: group.id)
        result
      end
    end
  end
end
