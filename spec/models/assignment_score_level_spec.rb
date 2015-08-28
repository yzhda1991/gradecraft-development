require 'spec_helper'

describe AssignmentScoreLevel do

  it "is valid with a name, a value, and an assignment" do
    assignment_score_level = AssignmentScoreLevel.new(
      name: "Level 1", value: "1000", assignment_id: "1")
    expect(assignment_score_level).to be_valid
  end

  it "is invalid without a name" do
    assignment_score_level = AssignmentScoreLevel.new(name: nil)
    expect(assignment_score_level).to_not be_valid
    expect(assignment_score_level.errors[:name].count).to eq 1
  end

  it "is invalid without an assignment" do
    assignment_score_level = AssignmentScoreLevel.new(assignment_id: nil)
    expect(assignment_score_level).to_not be_valid
    expect(assignment_score_level.errors[:assignment_id].count).to eq 1
  end

  it "is invalid without a value" do
    assignment_score_level = AssignmentScoreLevel.new(value: nil)
    expect(assignment_score_level).to_not be_valid
    expect(assignment_score_level.errors[:value].count).to eq 1
  end
end
