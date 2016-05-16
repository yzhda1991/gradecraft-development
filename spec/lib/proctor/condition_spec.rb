require 'proctor'

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
    it "should have a readable condition" do
      subject.instance_variable_set(:@condition, "condition stuff")
      expect(subject.condition).to eq "condition stuff"
    end

    it "should have a readable name" do
      subject.instance_variable_set(:@name, "name stuff")
      expect(subject.name).to eq "name stuff"
    end
  end

  describe "#failed?" do
  end

  describe "#passed?" do
  end
end
