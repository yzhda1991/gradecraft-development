describe Services::Actions::VerifiesAssignmentStudent do
  let(:course) { build_stubbed :course }
  let(:student) { create :user }
  let(:assignment) { create :assignment }
  let(:route_params) {{ "assignment_id" => assignment.id, "student_id" => student.id }}
  let(:raw_params) { RubricGradePUT.new(assignment).params.merge route_params }

  it "expects attributes to assign to assignment and student" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the found assignment" do
    result = described_class.execute raw_params: raw_params
    expect(result).to have_key :assignment
  end

  it "halts with error if assignment is not found" do
    raw_params["assignment_id"] = nil
    expect { described_class.execute raw_params: raw_params }.to \
      raise_error LightService::FailWithRollbackError
  end

  it "promises the found student" do
    result = described_class.execute raw_params: raw_params
    expect(result).to have_key :student
  end

  it "halts with error if student is not found" do
    raw_params["student_id"] = nil
    expect { described_class.execute raw_params: raw_params }.to \
      raise_error LightService::FailWithRollbackError
  end
end
