describe Services::Actions::SetExpectationsOnCriterion do
  let(:criterion) { create :criterion }
  let(:expected_level) { criterion.levels.last }

  let(:context) {{
      criterion: criterion,
      level: expected_level
    }}

  it "expects criterion" do
    context.delete(:criterion)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect a level" do
    context.delete(:level)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "sets the expected level id on the criterion" do
    result = described_class.execute context
    expect(criterion.meets_expectations_level_id).to eq expected_level.id
  end

  it "sets the expeted level's points on the criterion" do
    result = described_class.execute context
    expect(criterion.meets_expectations_points).to eq expected_level.points
  end
end
