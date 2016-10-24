require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/verifies_assignment_student"

describe Services::Actions::VerifiesAssignmentStudent do
  let(:world) { World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade, :badge, :group) }
  let(:route_params) {{ "assignment_id" => world.assignment.id, "student_id" => world.student.id }}
  let(:raw_params) { RubricGradePUT.new(world).params.merge route_params }

  it "expects attributes to assign to assignment and student" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the found assignment" do
    result = described_class.execute raw_params: raw_params
    expect(result).to have_key :assignment
  end

  it "returns the group if present" do
    raw_params["group_id"] = world.group.id
    result = described_class.execute raw_params: raw_params
    expect(result).to have_key :group
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
