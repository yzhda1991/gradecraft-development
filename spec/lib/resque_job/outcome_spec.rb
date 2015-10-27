require 'rails_spec_helper'

RSpec.describe ResqueJob::Outcome,  type: :vendor_library do
  describe "initialize" do
    it "should set the result" do
      outcome = ResqueJob::Outcome.new true
      expect(outcome.instance_variable_get(:@result)).to eq(true)
    end
  end

  describe "truthy?" do
    context "@result is neither false nor nil" do
      it "should be true" do
        outcome = ResqueJob::Outcome.new true
        expect(outcome.truthy?).to eq(true)
      end
    end

    context "@result is false" do
      it "should be false" do
        outcome = ResqueJob::Outcome.new false
        expect(outcome.truthy?).to eq(false)
      end
    end

    context "@result is nil" do
      it "should be false" do
        outcome = ResqueJob::Outcome.new nil
        expect(outcome.truthy?).to eq(false)
      end
    end
  end

  describe "falsey?" do
    context "@result is neither false nor nil" do
      it "should be false" do
        outcome = ResqueJob::Outcome.new true
        expect(outcome.falsey?).to eq(false)
      end
    end

    context "@result is false" do
      it "should be true" do
        outcome = ResqueJob::Outcome.new false
        expect(outcome.falsey?).to eq(true)
      end
    end

    context "@result is nil" do
      it "should be true" do
        outcome = ResqueJob::Outcome.new nil
        expect(outcome.falsey?).to eq(true)
      end
    end
  end

  describe "success?" do
    it "should be an alias for truthy?" do
      expect(ResqueJob::Outcome.new(true).success?).to eq(true)
      expect(ResqueJob::Outcome.new(false).success?).to eq(false)
      expect(ResqueJob::Outcome.new(nil).success?).to eq(false)
    end
  end

  describe "failure?" do
    it "should be an alias for falsey?" do
      expect(ResqueJob::Outcome.new(true).failure?).to eq(false)
      expect(ResqueJob::Outcome.new(false).failure?).to eq(true)
      expect(ResqueJob::Outcome.new(nil).failure?).to eq(true)
    end
  end
end
