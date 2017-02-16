require "spec_helper"

RSpec.describe ResqueJob::Performer, type: :vendor_library do
  let(:attrs) { Hash.new(color: "green") }
  let(:performer) { ResqueJob::Performer.new(attrs) }
  subject { performer }

  # TODO: add specs for all cases in subclassed conditions
  describe "initialize" do
    it "should set @attrs" do
      expect(subject.instance_variable_get(:@attrs)).to eq(attrs)
    end

    it "should set an empty array of @outcomes" do
      expect(subject.instance_variable_get(:@outcomes)).to eq([])
    end

    it "should set an empty array of @outcome_messages" do
      expect(subject.instance_variable_get(:@outcome_messages)).to eq([])
    end

    it "should setup the performer" do
      expect(subject).to receive(:setup)
      subject.instance_eval { initialize }
    end

    describe "logger" do
      let(:performer_with_logger) { ResqueJob::Performer.new(attrs, logger) }
      let(:logger) { Logger.new Tempfile.new("logger") }

      context "a logger is passed in on instantiation" do
        subject { performer_with_logger }

        it "sets the logger to @logger" do
          expect(performer_with_logger.instance_variable_get(:@logger)).to eq(logger)
        end
      end

      context "no logger is passed in" do
        subject { performer }
        it "sets @logger to nil" do
          expect(performer.instance_variable_get(:@logger)).to be_nil
        end
      end
    end
  end

  describe "do_the_work" do
    after(:each) do
      subject.do_the_work
    end

    it "should set a contrived require_success condition" do
      expect(subject).to receive(:require_success)
    end

    it "should receive a puts" do
      expect(subject).to receive(:puts)
    end
  end

  describe "#default_options" do
    subject { performer.default_options }
    it "doesn't skip setup by default" do
      expect(subject).to eq({skip_setup: false}.freeze)
    end

    it "doesn't allow changes to the returned value" do
      expect { subject[:snake] = "walrus" }.to raise_error(RuntimeError)
    end
  end

  describe "setup" do
    it "should have an empty setup method" do
      expect(subject.setup).to be_nil
    end
  end

  describe "add_message" do
    it "should add a message to @outcome_messages" do
      subject.add_message "a thing"
      expect(subject.outcome_messages).to eq([ "a thing" ])
    end

    it "should increase the size of outcome_messages by one" do
      expect{ subject.add_message("stuff") }.to change{ subject.outcome_messages.size }.by(1)
    end
  end

  describe "add_message" do
    it "should return @outcome_messages" do
      @outcome_messages = ["snake", "herring"]
      subject.instance_variable_set(:@outcome_messages, @outcome_messages)
      expect(subject.outcome_messages).to eq(@outcome_messages)
    end
  end

  describe "add_outcome_messages" do
    before { @messages = { failure: "stuff sucked", success: "stuff rocked" }}

    context "outcome is a failure" do
      before(:each) { @outcome = ResqueJob::Outcome.new(false) }

      context ":failure message is present" do
        it "should add the :failure message" do
          expect(subject).to receive(:add_message).with ("stuff sucked")
          subject.add_outcome_messages(@outcome, @messages)
        end
      end

      context ":failure message is not present" do
        it "should not add a failure message" do
          expect(subject).not_to receive(:add_message)
          subject.add_outcome_messages(@outcome, success: "stuff sucked")
        end
      end
    end

    context "outcome is a success" do
      before(:each) { @outcome = ResqueJob::Outcome.new(true) }

      context ":success message is present" do
        it "should add the :success message" do
          expect(subject).to receive(:add_message).with ("stuff rocked")
          subject.add_outcome_messages(@outcome, @messages)
        end
      end

      context ":success message is not present" do
        it "should not add a success message" do
          expect(subject).not_to receive(:add_message).with ("stuff rocked")
          subject.add_outcome_messages(@outcome, failure: "stuff sucked")
        end
      end
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
      expect(@performer.failures).to eq(@failures)
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
      expect(@performer.successes).to eq(@successes)
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
        expect(@performer.outcome_failure?).to be_truthy
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
        expect(@performer.outcome_success?).to be_truthy
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
      expect(ResqueJob::Outcome).to receive(:new).with("waffle", { max_result_size: false })

      @performer.require_success { "waffle" }
    end

    it "should add the new outcome to @outcomes" do
      expect do
        @performer.require_success { "waffle" }
      end.to change{ @performer.outcomes.size }.by(1)
    end

    it "should return the new outcome" do
      expect {|b| @performer.require_success(&b) }.to yield_with_no_args
    end

    context "no value is passed in the block" do
      it "should create a false outcome" do
        subject.require_success {}
        expect(subject.outcomes.first.result).to eq(false)
      end
    end

    describe "performer#add_outcome_messages" do
      it "should pass in an outcome and messages" do
        @outcome = double(:outcome)
        @messages = double(:messages)
        allow(ResqueJob::Outcome).to receive_messages(new: @outcome)
        expect(subject).to receive(:add_outcome_messages).with(@outcome, @messages)
        subject.require_success(@messages) {}
      end

      context "messages are empty" do
        it "should not add messages to the outcome" do
          expect(subject).not_to receive(:add_outcome_messages)
          subject.require_success({}) do; end
        end
      end

      context "messages are present" do
        it "should add messages to the outcome" do
          expect(subject).to receive(:add_outcome_messages)
          subject.require_success({success: "great stuff"}) do; end
        end
      end
    end
  end

  def setup_success_and_failure
    @failures= (1..2).collect {ResqueJob::Outcome.new(false) }
    @successes = (1..2).collect {ResqueJob::Outcome.new(true) }
    @all_outcomes = @successes + @failures
  end
end
