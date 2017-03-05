require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/builds_grade"

describe Services::Actions::BuildsGrade do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }
  let(:criteiron_grade) { create(:criterion_grade, criterion: criterion, student: student) }
  let(:badge) { create(:badge, course: course) }
  
  let(:attributes) { RubricGradePUT.new(world).params }
  let(:context) {{
      attributes: attributes,
      student: student,
      assignment: assignment,
      graded_by_id: professor.id
    }}

  it "expects attributes to assign to grade" do
    context.delete(:attributes)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect student to be added to the context" do
    context.delete(:student)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect assignment to be added to the context" do
    context.delete(:assignment)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the built grade" do
    result = described_class.execute context
    expect(result).to have_key :grade
  end

  it "adds attributes to the grade" do
    result = described_class.execute context
    expect(result[:grade].assignment_id).to eq assignment.id
    expect(result[:grade].student_id).to eq student.id
    expect(result[:grade].full_points).to eq assignment.full_points
    expect(result[:grade].raw_points).to eq assignment.full_points - 10
    expect(result[:grade].status).to eq "Released"
    expect(result[:grade].feedback).to eq "good jorb!"
    expect(result[:grade].adjustment_points).to eq -10
    expect(result[:grade].adjustment_points_feedback).to eq "reduced by 10 points"
    expect(result[:grade].graded_by_id).to eq(professor.id)
    expect(result[:grade].graded_at).to be_within(1.second).of(DateTime.now)
  end

  it "adds the group id if supplied" do
    context[:attributes]["group_id"] = 777
    result = described_class.execute context
    expect(result[:grade].group_id).to eq 777
  end
end
