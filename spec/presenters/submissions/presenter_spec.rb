require "spec_helper"
require "./app/presenters/submissions/presenter"

describe SubmissionPresenter do
  let(:assignment) { double(:assignment, id: 123) }
  let(:course) { double(:course, assignments: assignments) }
  let(:assignments) { double(:active_record_relation).as_null_object }

  subject { described_class.new assignment_id: assignment.id, course: course }

  describe "#assignment" do
    let(:result) { subject.assignment }

    before do
      allow(assignments).to receive(:find).with(assignment.id) { assignment }
    end

    it "returns the assignment with the given id" do
      expect(subject.assignment).to eq assignment
    end

    it "caches the assignment" do
      result
      expect(assignments).not_to receive(:find).with assignment.id
      result
    end

    it "sets the assignment to @assignment" do
      result
      expect(subject.instance_variable_get(:@assignment)).to eq assignment
    end
  end

  describe "#course" do
    it "is the course that is passed in as a property" do
      expect(subject.course).to eq course
    end
  end

  describe "#group" do
    let(:assignment) { double(:assignment, has_groups?: true) }
    let(:group_id) { 765 }
    subject { described_class.new group_id: group_id, course: course }

    before { allow(subject).to receive(:assignment).and_return assignment }

    it "is nil if the assignment does not allow groups" do
      allow(assignment).to receive(:has_groups?).and_return false
      expect(subject.group).to eq nil
    end

    it "returns the group from the group id that was passed in as a property" do
      group = double(:group)
      groups = double(:active_record_relation)
      allow(groups).to receive(:find).with(group_id).and_return group
      allow(course).to receive(:groups).and_return groups
      expect(subject.group).to eq group
    end

    it "caches the assignment" do
    end

    it "sets the assignment to @assignment" do
    end
  end
end
