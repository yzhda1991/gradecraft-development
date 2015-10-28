require "active_record_spec_helper"

describe AssignmentGroup do

  it "is valid with assignment and group" do
    @group = create(:group)
    assignment_group = AssignmentGroup.new(
      assignment_id: "10", group: @group)
    expect(assignment_group).to be_valid
  end

  it "is invalid without assignment" do
    assignment_group = AssignmentGroup.new(assignment_id: nil)
    expect(assignment_group).to_not be_valid
    expect(assignment_group.errors[:assignment_id].count).to eq 1
  end

  it "is invalid without group" do
    assignment_group = AssignmentGroup.new(group: nil)
    expect(assignment_group).to_not be_valid
    expect(assignment_group.errors[:group].count).to eq 1
  end

end
