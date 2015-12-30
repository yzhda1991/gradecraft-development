require "spec_helper"
require "active_support/inflector"
require "./lib/historical/date_history_token"

describe Historical::DateHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the key is an updated_at" do
      expect(described_class.tokenizable?("updated_at", nil, nil)).to eq true
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

      subject = described_class.new "updated_at", [nil, DateTime.new(2015, 4, 14, 2, 30)], Object

      expect(subject.parse).to eq({ date: "April 14th, 2015" })
    end
  end
end
