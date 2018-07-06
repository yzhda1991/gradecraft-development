describe Services::Actions::IteratesAssignmentGroupsToCreateGrades do
  let(:assignment) { create(:assignment) }
  let(:professor) { create(:user) }
  let(:context) { { assignment_id: assignment.id, grades_by_group_params: grades_by_group_params, graded_by_id: professor.id } }
  let(:grades_by_group_params) { { grades_by_group: {
    "0" => { "instructor_modified" => "true", "raw_points" => "10", "status" => "graded" },
    "1" => { "instructor_modified" => "true", "raw_points" => "20", "status" => "graded" } } }
  }

  it "expects an grades_by_group_params" do
    expect { described_class.execute assignment_id: assignment.id, graded_by_id: professor.id  }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects an assignment_id" do
    expect { described_class.execute grades_by_group_params: grades_by_group_params, graded_by_id: professor.id }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a graded_by_id" do
    expect { described_class.execute grades_by_group_params: grades_by_group_params, assignment_id: assignment.id }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the successful grades" do
    result = described_class.execute context
    expect(result).to have_key :successful
  end

  it "promises the unsuccessful grades" do
    result = described_class.execute context
    expect(result).to have_key :unsuccessful
  end

  it "iterates the assignment groups" do
    expect(Services::CreatesGroupGrades).to receive(:call).exactly(grades_by_group_params[:grades_by_group].length).times.and_call_original
    described_class.execute context
  end
end
