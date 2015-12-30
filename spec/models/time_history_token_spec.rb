require "spec_helper"
require "./app/models/time_history_token"

describe TimeHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is an updated_at" do
      expect(described_class.tokenizable?("updated_at", nil)).to eq true
    end
  end

  describe ".token" do
    it "returns time" do
      expect(described_class.token).to eq :time
    end
  end

  describe "#parse" do
    it "returns a string representation of the updated at timestamp" do
      subject = described_class.new "updated_at", [nil, DateTime.new(2015, 4, 14, 2, 31)], Object
      expect(subject.parse).to eq({ time: "2:31 AM" })
    end
  end
end
