describe Services::Actions::SetExpectationsOnLevels do
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

  it "sets the expected level to meets_expectations true" do
    result = described_class.execute context
    expect(expected_level.reload.meets_expectations).to eq true
  end

  it "sets the other levels to meets_expectations false" do
    result = described_class.execute context
    expect(criterion.levels.pluck(:meets_expectations)).to eq([false, true])
  end
end
