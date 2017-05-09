describe Services::Actions::RemoveExpectationsOnCriterion do
  let(:criterion) { create :criterion }

  let(:context) {{
      criterion: criterion
    }}

  it "expects criterion" do
    context.delete(:criterion)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "resets the expected level fields on the criterion" do
    criterion.update(meets_expectations_level_id: 1)
    criterion.update(meets_expectations_points: 1000)
    result = described_class.execute context
    expect(criterion.meets_expectations_level_id).to eq nil
    expect(criterion.meets_expectations_points).to eq 0
  end
end
