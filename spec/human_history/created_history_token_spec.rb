describe HumanHistory::CreatedHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is created_at" do
      expect(described_class.tokenizable?("created_at", nil, nil)).to eq true
    end
  end

  describe ".token" do
    it "returns change" do
      expect(described_class.token).to eq :change
    end
  end

  describe "#parse" do
    it "returns the object type that was created" do
      subject = described_class.new "created_at", [nil, DateTime.now], "Object"

      expect(subject.parse).to eq({ change: "the object" })
    end
  end
end
