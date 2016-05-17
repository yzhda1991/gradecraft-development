require "proctor"
require_relative "../../support/test_classes/lib/proctor/proctor_conditions_test_class"

describe Proctor::Conditions do
  # Proctor::Conditions is included in the test class
  describe ProctorConditionsTestClass do
    subject { described_class.new proctor: test_proctor}
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
      it "has a readable proctor" do
        subject.instance_variable_set :@proctor, "this is a proctor"
        expect(subject.proctor).to eq "this is a proctor"
      end
    end

    describe "inclusion behaviors" do
      it "resets the conditions" do
      end
    end

    describe "#initialize" do
      it "sets a proctor to @proctor" do
        expect(subject.proctor).to eq test_proctor
      end

      it "resets the conditions" do
        expect_any_instance_of(described_class).to receive(:reset_conditions)
        subject
      end

      it "raises an error if no proctor is given" do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end

    describe "deferring to the proctor" do
      # this is referencing defer_to_proctor :test_method in the test class
      it "should defer deferred methods to the proctor" do
        allow(test_proctor).to receive(:test_method) { "proctor output" }
        expect(subject.test_method).to eq "proctor output"
      end
    end
  end
end
