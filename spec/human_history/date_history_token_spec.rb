describe HumanHistory::DateHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is a recorded at" do
      expect(described_class.tokenizable?("recorded_at", nil, nil)).to eq true
    end
  end

  describe ".token" do
    it "returns date" do
      expect(described_class.token).to eq :date
    end
  end

  describe "#parse" do
    it "returns a string representation of the updated at timestamp" do
      class Integer
        def ordinalize
          ActiveSupport::Inflector.ordinalize(self)
        end
      end

      subject = described_class.new "recorded_at", DateTime.new(2015, 4, 14, 2, 30), Object

      expect(subject.parse).to eq({ date: "April 14th, 2015" })
    end
  end
end
