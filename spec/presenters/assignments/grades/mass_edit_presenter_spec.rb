require "spec_helper"
require "./app/presenters/assignments/grades/mass_edit_presenter"

describe Assignments::Grades::MassEditPresenter do
  let(:assignment) { double(:assignment) }
  subject { described_class.new }

  before(:each) { allow(subject).to receive(:assignment).and_return assignment }

  describe "#assignment" do
    it "returns the assignment" do
      expect(subject.assignment).to eq assignment
    end
  end

  describe "#grade_select?" do
    context "when assignment grade type is not a select list" do
      it "returns false" do
        allow(assignment).to receive(:grade_select?).and_return false
        expect(subject.grade_select?).to eq false
      end
    end

    context "when assignment grade type is a select list" do
      it "returns true" do
        allow(assignment).to receive(:grade_select?).and_return true
        expect(subject.grade_select?).to eq true
      end
    end
  end

  describe "#grade_radio?" do
    context "when assignment grading type is not radio buttons" do
      it "returns false" do
        allow(assignment).to receive(:grade_radio?).and_return false
        expect(subject.grade_radio?).to eq false
      end
    end

    context "when assignment grade type is radio buttons" do
      it "returns true" do
        allow(assignment).to receive(:grade_radio?).and_return true
        expect(subject.grade_radio?).to eq true
      end
    end
  end

  describe "#grade_checkboxes?" do
    context "when assignment grading type is not checkboxes" do
      it "returns false" do
        allow(assignment).to receive(:grade_checkboxes?).and_return false
        expect(subject.grade_checkboxes?).to eq false
      end
    end

    context "when assignment grade type is checkboxes" do
      it "returns true" do
        allow(assignment).to receive(:grade_checkboxes?).and_return true
        expect(subject.grade_checkboxes?).to eq true
      end
    end
  end

  describe "#pass_fail?" do
    context "when assignment grading type is not pass/fail" do
      it "returns false" do
        allow(assignment).to receive(:pass_fail?).and_return false
        expect(subject.pass_fail?).to eq false
      end
    end

    context "when assignment grade type is pass/fail" do
      it "returns true" do
        allow(assignment).to receive(:pass_fail?).and_return true
        expect(subject.pass_fail?).to eq true
      end
    end
  end

  describe "#full_points" do
    it "returns the assignment points" do
      allow(assignment).to receive(:full_points).and_return 9000
      expect(subject.full_points).to eq 9000
    end
  end

  describe "#groups" do
    it "returns the assignment groups" do
      groups = double(:groups, name: "Mock Group")
      allow(assignment).to receive(:groups).and_return groups
      expect(subject.groups).to eq groups
    end
  end

  describe "#assignment_score_levels" do
    it "returns ordered assignment_score_levels" do
      assignment_score_levels = double(:assignment_score_levels)
      allow(assignment).to receive(:assignment_score_levels).and_return assignment_score_levels
      allow(assignment_score_levels).to receive(:order_by_points).and_return assignment_score_levels
      expect(subject.assignment_score_levels).to eq assignment_score_levels
    end
  end

  describe "#grades_by_group" do
    let(:assignment_group_1) { double(:groups, group_id: 1, students: [ double(:student, id: 1) ]) }
    let(:assignment_group_2) { double(:groups, group_id: 2, students: [ double(:student, id: 2) ]) }
    let(:grade) { double(:grade) }

    it "returns grades organized by group" do
      allow(assignment).to receive(:groups).and_return [ assignment_group_1, assignment_group_2 ]
      allow(assignment).to receive(:id).and_return 1
      allow_any_instance_of(Gradebook).to receive(:grades).and_return [grade]

      result = subject.grades_by_group

      expect(result.count).to eq 2
      expect(result).to all include :group, :grade
    end
  end
end
