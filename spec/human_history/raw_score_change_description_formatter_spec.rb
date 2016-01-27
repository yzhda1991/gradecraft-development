require "spec_helper"
require "active_model"
require "./lib/human_history/raw_score_change_description_formatter"

describe HumanHistory::RawScoreChangeDescriptionFormatter do
  let(:attribute) { "raw_score" }
  let(:changes) { ["previous", "current"] }
  let(:type) { "Grade" }

  subject { described_class.new attribute, changes, type }

  describe "#formattable?" do
    class Grade
      extend ActiveModel::Translation
    end

    it "returns true if the attribute is raw score" do
      expect(subject).to be_formattable
    end

    it "returns false if the attribute is not raw score" do
      allow(subject).to receive(:attribute).and_return "blah"
      expect(subject).to_not be_formattable
    end

    it "returns false if the type is not a grade" do
      allow(subject).to receive(:type).and_return "Object"
      expect(subject).to_not be_formattable
    end
  end

  describe "#change_description" do
    it "returns the attribute name and changes" do
      expect(subject.change_description).to eq "the raw score to current"
    end
  end
end
