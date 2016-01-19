require "spec_helper"
require "active_model"
require "./lib/human_history/change_history_token"

describe HumanHistory::ChangeHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the value is an array" do
      expect(described_class.tokenizable?("blah", [], {})).to eq true
    end

    it "is tokenizable if there is not a created at change within the changeset" do
      expect(described_class.tokenizable?("blah", [], { "created_at" => [nil, DateTime.new(2015, 4, 15, 1, 22)]})).to eq false
    end
  end

  describe ".token" do
    it "returns change" do
      expect(described_class.token).to eq :change
    end
  end

  describe "#parse" do
    class Object
      extend ActiveModel::Translation
    end

    it "returns the attribute and the changes" do
      subject = described_class.new "blah_date", ["old", "new"], "Object"

      expect(subject.parse).to eq({ change: "the blah date from \"old\" to \"new\"" })
    end

    it "does not include a 'from' if the previous value was nil" do
      subject = described_class.new "blah_date", [nil, "new"], "Object"

      expect(subject.parse).to eq({ change: "the blah date to \"new\"" })
    end
  end
end
