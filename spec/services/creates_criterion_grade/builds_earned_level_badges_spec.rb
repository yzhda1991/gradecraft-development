require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_criterion_grade/builds_earned_level_badges"

describe Services::Actions::BuildsEarnedLevelBadges do

  let(:raw_params) { RubricGradePUT.new.params }
  let(:context) {{
      raw_params: raw_params,
      student_visible_status: true,
      student: User.find(raw_params["student_id"]),
      assignment: Assignment.find(raw_params["assignment_id"])
    }}

  it "expects attributes to assign to criterion grades" do
    context.delete(:raw_params)
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

  it "expect student visible status to be added to the context" do
    context.delete(:student_visible_status)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the built earned level badges" do
    result = described_class.execute context
    expect(result).to have_key :earned_level_badges
  end

  it "builds an earned badge for each record in the params" do
    pending "add level params to RubricGradePUT"
    result = described_class.execute context
    expect(result[:earned_level_badges].length).to \
      eq(raw_params["level_badge"].length)
  end
end
