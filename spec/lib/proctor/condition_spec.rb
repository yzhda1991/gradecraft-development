require 'proctor/override'

describe Proctor::Condition do
  subject { described_class.new name: "Some Name" }

  describe "#initialize" do
    it "takes a name as a required keyword argument" do
      expect(subject.name).to eq "Some Name"
    end

    it "takes a condition as a block but doesn't call it" do
      override = described_class.new name: "Some Name" do
        "some-value" == "some-different-thing"
      end
      expect(override.condition.class).to eq Proc
      expect(override.condition.call).to eq false
    end
  end

  describe "readable attributes" do
  end

  describe "#failed?" do
  end

  describe "#passed?" do
  end
end
