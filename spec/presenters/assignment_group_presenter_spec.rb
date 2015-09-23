require "rspec/core"
require "./app/presenters/assignment_group_presenter"

describe AssignmentGroupPresenter do
  let(:assignment) { double(:assignment) }
  let(:group) { double(:group, name: "My Group") }
  let(:submission) { double(:submission) }
  subject { AssignmentGroupPresenter.new({ assignment: assignment, group: group })}

  describe "#has_submission?" do
    it "has a submission if one is returned for the assignment" do
      allow(group).to receive(:submission_for_assignment).and_return submission
      expect(subject).to have_submission
    end
  end

  describe "#submission" do
    it "returns the submission for the assignment" do
      allow(group).to receive(:submission_for_assignment).and_return submission
      expect(subject.submission).to eq submission
    end
  end

  describe "#title" do
    it "has the group name" do
      expect(subject.title).to eq "My Group Grades"
    end
  end
end
