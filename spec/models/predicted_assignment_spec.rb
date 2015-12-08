require "active_record_spec_helper"
require "./app/models/predicted_assignment"

describe PredictedAssignment do
  let(:assignment) { create :assignment }
  let(:user) { create :user }
  subject { described_class.new assignment, user }

  it "responds to any method on the assignment" do
    expect(subject.id).to eq assignment.id
  end

  describe "#grade" do
    it "creates a grade if it does not have one for the assignment" do
      current_time = DateTime.now
      grade = subject.grade
      expect(Grade.find(grade.id).created_at).to be > current_time
    end

    it "returns the grade if one already exists for the user and assignment" do
      existing_grade = Grade.create(assignment: assignment, student: user)
      expect(subject.grade.id).to eq existing_grade.id
    end

    it "returns an instance of a predicted grade" do
      expect(subject.grade).to be_instance_of PredictedGrade
    end
  end
end

