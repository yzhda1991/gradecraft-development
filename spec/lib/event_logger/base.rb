require 'rails_spec_helper'

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe EventLogger::Base, type: :background_job do
  let(:backoff_strategy) { [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780, 900, 1140, 1380, 1520, 1760, 3600, 7200, 14400, 28800] }

  describe "self.perform" do
    before do
      @now = Time.parse "Oct 20 1985"
      @mongoid_event = double(:mongoid_event)
      allow(described_class).to receive(:notify_event_outcome).and_return "another message"
    end

    it "should print the @start_message class instance variable to the log" do
      described_class.instance_variable_set(:@start_message, "some message")
      allow(Analytics::Event).to receive(:create) { true }
      expect(described_class).to receive(:puts).with("some message")
      expect(described_class).to receive(:puts).with("another message")
      described_class.perform "event"
    end

    it "should create a new analytics event using the event attrs" do
      allow(described_class).to receive_messages(event_type: "event", data: {created_at: @now})
      expect(Analytics::Event).to receive(:create).with described_class.event_attrs("event", {created_at: @now})
      described_class.perform "event", created_at: @now
    end

    it "should notify the event outcome to the log" do
      allow(Analytics::Event).to receive_messages(create: @mongoid_event)
      expect(described_class).to receive(:notify_event_outcome).with(@mongoid_event, {caruthers: "stew"})
      described_class.perform "event", {caruthers: "stew"}
    end
  end

  describe "self.notify_event_outcome(event, data)" do
    let(:valid_event) { double(Logger, valid?: true ) }
    let(:invalid_event) { double(Logger, valid?: false ) }

    before do
      described_class.instance_variable_set(:@success_message, "great stuff happened")
      described_class.instance_variable_set(:@failure_message, "bad stuff happened")
    end

    context "the event is valid" do
      let(:notify_success) { "great stuff happened with data {:heads=>5}" }

      it "should output the @success_message" do
        allow(Analytics::Event).to receive(:create) { valid_event }
        expect(described_class).to receive(:notify_event_outcome).with(valid_event, {heads: 5}) { notify_success }
        described_class.perform "event", {heads: 5}
      end
    end

    context "the event is not valid" do
      let(:notify_failure) { "bad stuff happened with data {:heads=>10}" }

      it "should output the @failure_message" do
        allow(Analytics::Event).to receive(:create) { invalid_event }
        expect(described_class).to receive(:notify_event_outcome).with(invalid_event, {heads: 10}) { notify_failure}
        described_class.perform "event", {heads: 10}
      end
    end
  end

  describe "self.event_attrs(event_type, data)" do
    before do
      @now = Time.parse "Jun 20 1942"
      @base_attrs = { event_type: "waffle", created_at: @now }
    end

    it "should return an array of required attributes by default" do
      expect(described_class).to receive(:event_attrs).and_return @base_attrs
      allow(Time).to receive_messages(now: @now)
      described_class.event_attrs("waffle")
    end

    it "should merge the options in the data hash" do
      @later = Time.parse "Jan 9 2055"
      expect(described_class).to receive(:event_attrs).and_return @base_attrs.merge(created_at: @later)
      described_class.event_attrs("waffle", created_at: @later)
    end
  end

  describe "extensions" do
    it "should use resque-retry" do
      expect(described_class).to respond_to(:retry_delay)
    end
  end

  describe "class-level instance variable defaults" do
    it "should have a default @queue" do
      described_class.instance_variable_set(:@queue, :herman)
      expect(described_class.instance_variable_get(:@queue)).to eq(:herman)
    end

    it "should not have a default @retry_limit for resque-retry" do
      expect(described_class.instance_variable_get(:@retry_limit)).to eq(nil)
    end

    it "should not have a default @retry_delay for resque-retry" do
      expect(described_class.instance_variable_get(:@retry_delay)).to eq(nil)
    end

    it "should have a default @backoff_strategy for resque-retry" do
      expect(described_class.instance_variable_get(:@backoff_strategy)).to eq(backoff_strategy)
    end
  end

  describe "subclass inheritance" do
    it "should pass class-level instance variables to subclasses" do
      described_class.instance_variable_set(:@wallaby_necks, 5)
      allow(described_class).to receive(:instance_variable_names).and_return ["@wallaby_necks"]
      class Wallabydescribed_class < described_class; end
      expect(Wallabydescribed_class.instance_variable_get(:@wallaby_necks)).to eq(5)
    end

    it "should pass some actual values to subclasses" do
      class Pseudodescribed_class < described_class; end
      expect(Pseudodescribed_class.instance_variable_get(:@backoff_strategy)).to eq(backoff_strategy)
    end
  end

  describe "self.instance_variable_names" do
    before do
      allow(described_class).to receive(:inheritable_attributes) { [:ostriches, :badgers] }
    end

    it "should return an array of instance variable names" do
      expect(described_class.instance_variable_names).to include("@ostriches", "@badgers")
    end
  end
end
