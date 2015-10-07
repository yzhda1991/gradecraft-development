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
    before do
      setup_success_and_failure # @failures, @successes, @all_outcomes, and @performer
    end

    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
      @performer.instance_variable_set(:@outcomes, @all_outcomes)
    end

    it "should select the outcomes that have failed" do
      @performer.failures.should == @failed_outcomes
    end

    it "should not re-run if @failures already exists" do
      @performer.failures # should cache the @failures value
      expect(@performer.instance_variable_get(:@outcomes)).not_to receive(:select)
      @performer.failures
    end
  end

  describe "successes" do
    before do
      setup_success_and_failure # @failures, @successes, @all_outcomes, and @performer
    end

    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
      @performer.instance_variable_set(:@outcomes, @all_outcomes)
    end

    it "should select the outcomes that have succeeded" do
      @performer.successes.should == @successful_outcomes
    end

    it "should not re-run if @successes already exists" do
      @performer.successes # should cache the @successes value
      expect(@performer.instance_variable_get(:@outcomes)).not_to receive(:select)
      @performer.successes
    end
  end

  describe "outcome_success?" do
    before do
      setup_success_and_failure # @failures, @successes, @all_outcomes, and @performer
    end

    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
    end

    context "has successes and doesn't have failures" do
      it "should be true" do
        @performer.instance_variable_set(:@outcomes, @successes)
        expect(@performer.outcome_success?).to be_truthy
      end
    end

    context "has successes but also has failures" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, @all_outcomes)
        expect(@performer.outcome_success?).to be_falsey
      end
    end

    context "has neither successes nor failures" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, [])
        expect(@performer.outcome_success?).to be_falsey
      end
    end

    context "has failures but no successes" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, @failures)
        expect(@performer.outcome_success?).to be_falsey
      end
    end
  end

  describe "outcome_failure?" do
    before do
      setup_success_and_failure # @failures, @successes, @all_outcomes, and @performer
    end

    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
    end

    context "has failures but no successes" do
      it "should be true" do
        @performer.instance_variable_set(:@outcomes, @failures)
        expect(@performer.outcome_failure?).to be_truthy
      end
    end

    context "has successes and doesn't have failures" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, @successes)
        expect(@performer.outcome_failure?).to be_falsey
      end
    end

    context "has successes but also has failures" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, @all_outcomes)
        expect(@performer.outcome_failure?).to be_falsey
      end
    end

    context "has neither successes nor failures" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, [])
        expect(@performer.outcome_failure?).to be_falsey
      end
    end
  end

  describe "has_failures?" do
    before do
      setup_success_and_failure # @failures, @successes, @all_outcomes, and @performer
    end

    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
    end

    context "zero failures present" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, @successes)
        expect(@performer.outcome_failure?).to be_falsey
      end
    end
    
    context "some failures present" do
      it "should be true" do
        @performer.instance_variable_set(:@outcomes, @failures)
        expect(@performer.outcome_failure?).to be_true
      end
    end
  end

  describe "has_successes?" do
    before do
      setup_success_and_failure # @failures, @successes, @all_outcomes, and @performer
    end

    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
    end

    context "zero successes present" do
      it "should be false" do
        @performer.instance_variable_set(:@outcomes, @failures)
        expect(@performer.outcome_success?).to be_falsey
      end
    end
    
    context "some successes present" do
      it "should be true" do
        @performer.instance_variable_set(:@outcomes, @successes)
        expect(@performer.outcome_success?).to be_true
      end
    end
  end

  describe "require_success" do
    before(:each) do
      @performer = ResqueJob::Performer.new(attrs)
    end

    it "should yield the contents of the block" do
      expect {|b| @performer.require_success(&b) }.to yield_with_no_args
    end

    it "should build a new outcome with the yield of the block" do
      expect(ResqueJob::Outcome).to receive(:new).with("waffle")
      @performer.require_success { "waffle" }
    end

    it "should add the new outcome to @outcomes" do
      @waffle_outcome = ResqueJob::Outcome.new("waffle")
      @performer.instance_variable_set(:@outcomes, [])
      allow(ResqueJob::Outcome).to receive(:new).with("waffle") { @waffle_outcome }
      expect(@performer.instance_variable_get(:@outcomes)).to receive(:<<).with(@waffle_outcome)
      @performer.require_success { "waffle" }
      expect(@performer.outcomes).to eq([@waffle_outcome])
    end

    it "should return the new outcome" do
      expect {|b| @performer.require_success(&b) }.to yield_with_no_args
    end
  end

  def setup_success_and_failure
    @failed_outcomes = (1..2).collect {ResqueJob::Outcome.new(false) }
    @successful_outcomes = (1..2).collect {ResqueJob::Outcome.new(true) }
    @all_outcomes = successful_outcomes + failed_outcomes 
  end
end
