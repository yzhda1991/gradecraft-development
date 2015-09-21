require "rspec/core"
require "./app/presenters/assignment_presenter"

describe AssignmentPresenter do
  let(:assignment) { double(:assignment, name: "Crazy Wizardry", pass_fail?: false, point_total: 5000)}
  let(:view_context) { double(:view_context) }
  subject { AssignmentPresenter.new({ assignment: assignment, view_context: view_context }) }

  describe "#assignment" do
    it "is the assignment that is passed in as a property" do
      expect(subject.assignment).to eq assignment
    end
  end

  describe "#title" do
    it "is the assignment name and total points available" do
      allow(view_context).to receive(:number_with_delimiter).with(5000).and_return "5,000"
      expect(subject.title).to eq "Crazy Wizardry (5,000 points)"
    end

    it "is the assigment name and pass fail" do
      allow(view_context).to receive(:term_for).with(:pass).and_return "Pass"
      allow(view_context).to receive(:term_for).with(:fail).and_return "Fail"
      allow(assignment).to receive(:pass_fail?).and_return true
      expect(subject.title).to eq "Crazy Wizardry (Pass/Fail)"
    end
  end
end
