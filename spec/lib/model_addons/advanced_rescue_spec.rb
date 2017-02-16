require "spec_helper"

# test logging on a waffle
class Pancake
  include ModelAddons::ImprovedLogging
  include ModelAddons::AdvancedRescue

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def attributes
    { some_attr: "great_stuff" }
  end

  def failed_method
    rescue_with_logging "well that failed" do
      raise "this block totally failed error"
    end
  end

  def failed_method_no_logging
    rescue_with_logging "well that failed", log_errors: false do
      raise "this block totally failed error"
    end
  end

  def successful_method
    rescue_with_logging "better than nothing" do
      "some normal output"
    end
  end

  def caller_parent4; caller_parent3; end

  def caller_parent3; caller_parent2; end

  def caller_parent2; caller_parent1; end
  
  def caller_parent1; caller_method; end
end

RSpec.describe ModelAddons::AdvancedRescue, type: :vendor_library do
  before { @pancake= Pancake.new }

  describe "rescue_with" do
    context "the block yield raises an error" do
      subject { @pancake.failed_method }

      it "rescues out to a returned value" do
        expect(subject).to eq("well that failed")
      end

      context "log_errors is true" do
        it "logs an error with caller attributes" do
          expect(@pancake).to receive(:log_error_with_attributes)
          subject
        end
      end

      context "log_errors is false" do
        subject { @pancake.failed_method_no_logging }

        it "doesn't log the error" do
          expect(@pancake).not_to receive(:log_error_with_attributes)
          subject
        end
      end
    end

    context "the block yield succeeds without error" do
      subject { @pancake.successful_method }

      it "returns the value of the block" do
        expect(subject).to eq("some normal output")
      end
    end
  end

  describe "error_message" do
    it "returns a formatted error message for logging" do
      expected_message = "Pancake#some_weird_method was rescued to badger mouths"
      allow(@pancake).to receive(:caller_method) { "some_weird_method" }
      expect(@pancake.instance_eval { rescued_error_message("badger mouths") }).to eq(expected_message)
    end
  end

  describe "#caller_method" do
    it "returns the name of the containing parent method from the model" do
      expect(@pancake.instance_eval { caller_parent4 }).to eq("caller_parent4")
    end
  end
end
