describe Services::Actions::AssertResultFromManyOutcomes do
  it "expects unsuccessful" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "when there are unsuccessful outcomes" do
    let(:unsuccessful) { [:value_1, :value_2] }

    it "fails the context" do
      result = described_class.execute({ unsuccessful: unsuccessful })
      expect(result.success?).to be_falsey
    end
  end

  context "when there are no unsuccessful outcomes" do
    let(:unsuccessful) { [] }

    it "does not fail the context" do
      result = described_class.execute({ unsuccessful: unsuccessful })
      expect(result.success?).to be_truthy
    end
  end
end
