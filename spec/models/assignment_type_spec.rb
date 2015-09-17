# spec/models/assignment_type_spec.rb

describe AssignmentType do

  #simple validations
  it "is valid with a name" do
    assignment_type = AssignmentType.new(
      name: "Level 1" )
    expect(assignment_type).to be_valid
  end

  it "is invalid without a name" do
    assignment_type = AssignmentType.new(name: nil)
    expect(assignment_type).to_not be_valid
    expect(assignment_type.errors[:name].count).to eq 1
  end

end
