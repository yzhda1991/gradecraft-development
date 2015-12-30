require "spec_helper"
require "active_model"
require "./app/models/change_history_token"

describe ChangeHistoryToken do
  describe ".tokenizable?" do
    it "is tokenizable if the value is an array" do
      expect(described_class.tokenizable?("blah", [], {})).to eq true
    end
  end

  describe ".token" do
    it "returns change" do
      expect(described_class.token).to eq :change
    end
  end

  describe "#parse" do
    it "returns the attribute and the changes" do
      class String
        def classify
          ActiveSupport::Inflector.classify(self)
        end
      end
      class Object
        extend ActiveModel::Translation
      end

      subject = described_class.new "blah_date", ["old", "new"], "Object"

      expect(subject.parse).to eq({ change: "the blah date from \"old\" to \"new\"" })
    end
  end
end
