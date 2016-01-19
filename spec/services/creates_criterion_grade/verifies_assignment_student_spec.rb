require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_criterion_grade/verifies_assignment_student"

describe Services::Actions::VerifiesAssignmentStudent do
  let(:raw_params) { RubricGradePUT.new.params }

  it "expects attributes to assign to assignment and student" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the found assignment" do
    result = described_class.execute raw_params: raw_params
    expect(result).to have_key :assignment
  end

  it "halts with error if assignment is not found" do
    raw_params["assignment_id"] = 1000
    expect { described_class.execute raw_params: raw_params }.to \
      raise_error LightService::FailWithRollbackError
  end

  it "promises the found student" do
    result = described_class.execute raw_params: raw_params
    expect(result).to have_key :assignment
  end

  it "halts with error if student is not found" do
    raw_params["student_id"] = 1000
    expect { described_class.execute raw_params: raw_params }.to \
      raise_error LightService::FailWithRollbackError
  end
end
