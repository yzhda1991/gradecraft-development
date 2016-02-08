require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/builds_grade"

describe Services::Actions::BuildsGrade do

  let(:attributes) { RubricGradePUT.new.params }
  let(:context) {{
      attributes: attributes,
      student: User.find(attributes["student_id"]),
      assignment: Assignment.find(attributes["assignment_id"])
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
    expect(result[:grade].assignment_id).to eq attributes["assignment_id"]
    expect(result[:grade].student_id).to eq attributes["student_id"]
    expect(result[:grade].point_total).to eq attributes["points_possible"]
    expect(result[:grade].raw_score).to eq attributes["points_given"]
    expect(result[:grade].status).to eq "Released"
    expect(result[:grade].feedback).to eq "good jorb!"
  end
end
