require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/verifies_assignment_student"

describe Services::Actions::VerifiesAssignmentStudent do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }
  let(:criterion_grade) { create(:criterion_grade, criterion: criterion) }
  let(:badge) { create(:badge, course: course) }
  let(:group) { create(:group, assignments: [assignment]) }
  let(:route_params) {{ "assignment_id" => assignment.id, "student_id" => student.id }}
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
    raw_params["group_id"] = group.id
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
