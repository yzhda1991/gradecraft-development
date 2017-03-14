describe HumanHistory::EventHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is an event" do
      expect(described_class.tokenizable?("event", nil, nil)).to eq true
    end
  end

  describe ".token" do
    it "returns event" do
      expect(described_class.token).to eq :event
    end
  end

  describe "#parse" do
    it "returns `changed` if the event is update" do
      subject = described_class.new "event", "update", Object
      expect(subject.parse).to eq({ event: "changed" })
    end

    it "returns `created` if the event is not update" do
      subject = described_class.new "event", "create", Object
      expect(subject.parse).to eq({ event: "created" })
    end
  end
end
