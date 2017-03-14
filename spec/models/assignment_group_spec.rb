describe AssignmentGroup do

  it "is valid with assignment and group" do
    assignment = create(:assignment)
    group = create(:group)
    assignment_group = AssignmentGroup.new(assignment: assignment, group: group)
    expect(assignment_group).to be_valid
  end

  it "is invalid without assignment" do
    assignment_group = AssignmentGroup.new(assignment_id: nil)
    expect(assignment_group).to_not be_valid
    expect(assignment_group.errors[:assignment].count).to eq 1
  end

  it "is invalid without group" do
    assignment_group = AssignmentGroup.new(group: nil)
    expect(assignment_group).to_not be_valid
    expect(assignment_group.errors[:group].count).to eq 1
  end

end
