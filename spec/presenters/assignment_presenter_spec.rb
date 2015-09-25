require "rspec/core"
require "./app/presenters/assignment_presenter"
require "./app/presenters/assignment_group_presenter"

describe AssignmentPresenter do
  let(:assignment) { double(:assignment, name: "Crazy Wizardry", pass_fail?: false, point_total: 5000)}
  let(:course) { double(:course) }
  let(:view_context) { double(:view_context) }
  let(:team) { double(:team) }
  subject { AssignmentPresenter.new({ assignment: assignment, course: course, view_context: view_context }) }

  describe "#assignment" do
    it "is the assignment that is passed in as a property" do
      expect(subject.assignment).to eq assignment
    end
  end

  describe "#course" do
    it "returns the course that is passed in as a property" do
      expect(subject.course).to eq course
    end
  end

  describe "#for_team?" do
    it "returns false if there was not a team id specified" do
      expect(subject.for_team?).to eq false
    end

    it "returns false if the team was not found on the course" do
      subject.properties[:team_id] = 123
      allow(subject.course).to receive(:teams).and_return double(:relation, find_by: nil)
      expect(subject.for_team?).to eq false
    end

    it "returns true if the team was found" do
      subject.properties[:team_id] = 123
      allow(subject.course).to receive(:teams).and_return double(:relation, find_by: team)
      expect(subject.for_team?).to eq true
    end
  end

  describe "#groups" do
    it "wraps the assignment groups in an AssignmentGroupPresenter" do
      groups = [double(:group), double(:group)]
      allow(assignment).to receive(:groups).and_return groups
      expect(subject.groups.map(&:class).uniq).to eq [AssignmentGroupPresenter]
      expect(subject.groups.first.group).to eq groups.first
    end
  end

  describe "#hide_analytics?" do
    it "is not hidden if the course does not hide analytics" do
      allow(course).to receive(:hide_analytics?).and_return false
      expect(subject.hide_analytics?).to eq false
    end

    it "is not hidden if the assignment does not hide analytics" do
      allow(course).to receive(:hide_analytics?).and_return true
      allow(assignment).to receive(:hide_analytics?).and_return false
      expect(subject.hide_analytics?).to eq false
    end

    it "is hidden if both the assignment and course hide analytics" do
      allow(course).to receive(:hide_analytics?).and_return true
      allow(assignment).to receive(:hide_analytics?).and_return true
      expect(subject.hide_analytics?).to eq true
    end
  end

  describe "#rubric_available?" do
    let(:rubric) { double(:rubric, designed?: true) }

    it "is not available if there is no rubric attached to the assignment" do
      allow(assignment).to receive(:use_rubric?).and_return true
      allow(assignment).to receive(:rubric).and_return nil
      expect(subject.rubric_available?).to eq false
    end

    it "is not available if the assignment should not use a rubric" do
      allow(assignment).to receive(:use_rubric?).and_return false
      allow(assignment).to receive(:rubric).and_return rubric
      expect(subject.rubric_available?).to eq false
    end

    it "is not available if the rubric was not designed" do
      allow(assignment).to receive(:use_rubric?).and_return true
      allow(assignment).to receive(:rubric).and_return rubric
      allow(rubric).to receive(:designed?).and_return false
      expect(subject.rubric_available?).to eq false
    end

    it "is available if the rubric is designed and the assignment should use it" do
      allow(assignment).to receive(:use_rubric?).and_return true
      allow(assignment).to receive(:rubric).and_return rubric
      expect(subject.rubric_available?).to eq true
    end
  end

  describe "#students" do
    let(:student) { double(:user) }

    it "returns the students that are attached to the course" do
      allow(course).to receive(:students).and_return [student]
      expect(subject.students).to eq [student]
    end

    it "returns the students that are attached to the course for the team if a team is specified" do
      subject.properties[:team_id] = 123
      allow(course).to receive(:teams).and_return double(:relation, find_by: team)
      allow(course).to receive(:students_by_team).and_return [student]
      expect(subject.students).to eq [student]
    end
  end

  describe "#team" do
    it "returns the team for the team id from the course" do
      allow(course).to receive(:teams).and_return double(:relation, find_by: team)
      expect(subject.team).to eq team
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
