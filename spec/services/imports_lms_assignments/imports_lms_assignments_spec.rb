describe Services::Actions::ImportsLMSAssignments do
  let(:assignment) { Assignment.unscoped.last }
  let(:assignments) { [{ "id" => "ASSIGNMENT_1", "name" => "Assignment 1" }] }
  let(:assignment_type) { create :assignment_type, course: course }
  let(:course) { create :course }
  let(:provider) { :canvas }

  it "expects assignments to import" do
    expect { described_class.execute course: course,
             assignment_type_id: assignment_type.id, provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a course to create the assignments for" do
    expect { described_class.execute assignments: assignments,
             assignment_type_id: assignment_type.id, provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects an assignment type id to create the assignments for" do
    expect { described_class.execute assignments: assignments,
             course: course, provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a provider to create the correct importer object" do
    expect { described_class.execute assignments: assignments,
             assignment_type_id: assignment_type.id, course: course }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "creates the assignments" do
    result = described_class.execute assignments: assignments,
      assignment_type_id: assignment_type.id, course: course, provider: provider

    expect(result.import_result.successful.count).to eq 1
    expect(assignment.name).to eq "Assignment 1"
    expect(assignment.course).to eq course
    expect(assignment.assignment_type_id).to eq assignment_type.id
  end
end
