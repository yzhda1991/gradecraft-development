require "proctor"
require_relative "../../support/test_classes/lib/proctor/proctor_conditions_test_class"

describe Proctor::Conditions do
  # Proctor::Conditions is included in the test class
  subject { ProctorConditionsTestClass.new proctor: test_proctor}
  let(:test_proctor) { double(:test_proctor).as_null_object }

  describe "accessible attributes" do
    it "has accessible requirements" do
      subject.requirements = "some value"
      expect(subject.requirements).to eq "some value"
    end

    it "has accessible overrides" do
      subject.overrides = "another value"
      expect(subject.overrides).to eq "another value"
    end
  end

  describe "readable attributes" do
  end

  describe "inclusion behaviors" do
    it "resets the conditions" do
    end
  end

  describe "#initialize" do
  end

  describe "deferring to the proctor" do
  end
end
