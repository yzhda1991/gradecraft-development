describe Services::Actions::RemoveExpectationsOnLevels do
  let(:criterion) { create :criterion }
  let(:last_expected_level) { create :level, criterion: criterion, meets_expectations: true }

  let(:context) {{
      criterion: criterion
    }}

  it "expects criterion" do
    context.delete(:criterion)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "sets all levels to meets_expectations false" do
    last_expected_level
    result = described_class.execute context
    expect(criterion.levels.reload.pluck(:meets_expectations).uniq).to eq([false])
  end
end
