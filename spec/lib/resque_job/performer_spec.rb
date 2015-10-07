require 'spec_helper'

RSpec.describe ResqueJob::Performer, type: :vendor_library do
  let(:attrs) { Hash.new(color: "green") }
  subject { ResqueJob::Performer.new(attrs) }

  describe "initialize" do
    it "should set @attrs" do
      expect(subject.instance_variable_get(:@attrs)).to eq(attrs)
    end

    it "should set an empty array of @outcomes" do
      expect(subject.instance_variable_get(:@outcomes)).to eq([])
    end
  end

  describe "do_the_work" do
    it "should set a contrived require_success condition" do
      expect(subject).to receive(:require_success)
    end

    it "should receive a puts" do
      expect(subject).to receive(:puts)
    end
  end

  describe "setup" do
    it "should have an empty setup method" do
      expect(subject.setup).to be_nil
    end
  end

  describe "outcome_messages" do
    it "should put a message" do
      expect(subject).to receive(:puts)
    end
  end

  describe "failures" do
    it "should select the outcomes that have failed" do
    end

    it "should not re-run if @failures already exists" do
    end
  end

  describe "successes" do
    it "should select the outcomes that have succeeded" do
    end

    it "should not re-run if @successes already exists" do
    end
  end

  describe "outcome_success?" do
    context "has successes and doesn't have failures" do
      it "should be true" do
      end
    end

    context "has successes but also has failures" do
      it "should be false" do
      end
    end

    context "has neither successes nor failures" do
      it "should be false" do
      end
    end

    context "has failures but no successes" do
      it "should be false" do
      end
    end
  end

  describe "outcome_failure?" do
    context "has failures but no successes" do
      it "should be true" do
      end
    end

    context "has successes and doesn't have failures" do
      it "should be false" do
      end
    end

    context "has successes but also has failures" do
      it "should be false" do
      end
    end

    context "has neither successes nor failures" do
      it "should be false" do
      end
    end
  end

  describe "has_failures?" do
  end

  describe "has_successes?" do
  end

  describe "require_success" do
  end
end
