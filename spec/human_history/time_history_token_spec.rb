describe HumanHistory::TimeHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is a recorded at" do
      expect(described_class.tokenizable?("recorded_at", nil, nil)).to eq true
    end
  end

  describe ".token" do
    it "returns time" do
      expect(described_class.token).to eq :time
    end
  end

  describe "#parse" do
    it "returns a string representation of the recorded at timestamp" do
      subject = described_class.new "recorded_at", DateTime.new(2015, 4, 14, 2, 31), Object

      expect(subject.parse).to eq({ time: "2:31 AM" })
    end
  end
end
