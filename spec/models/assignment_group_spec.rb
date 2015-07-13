# spec/models/assignment_group_spec.rb

require 'spec_helper'

describe AssignmentGroup do

  it "is valid with assignment and group" do
    @group = create(:group)
    assignment_group = AssignmentGroup.new(
      assignment_id: "10", group: @group)
    expect(assignment_group).to be_valid
  end

  it "is invalid without assignment" do
    expect(AssignmentGroup.new(assignment_id: nil)).to have(1).errors_on(:assignment_id)
  end

  it "is invalid without group" do
    expect(AssignmentGroup.new(group: nil)).to have(1).errors_on(:group)
  end

end
