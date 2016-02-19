require 'active_record_spec_helper'

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe EventLogger::Base, type: :background_job do
  let(:backoff_strategy) { [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780, 900, 1140, 1380, 1520, 1760, 3600, 7200, 14400, 28800] }

  let(:event_type) { "waffle" }
  let(:some_data) {{ some: "new weird data" }}
  let(:time_now) { Time.parse "Jun 20 1942" }
  let(:mongoid_event) { double(:mongoid_event) }
  let(:analytics_attrs) {{ event_type: event_type, created_at: time_now }.merge(some_data) }

  describe "self.perform" do
    subject { described_class.perform(event_type, some_data) }

    before do
      allow(Time.zone).to receive(:now) { time_now }
      allow(described_class).to receive(:notify_event_outcome).and_return "another message"
    end

    it "should send a start message an event outcome message to the logger" do
      described_class.instance_variable_set(:@start_message, "mario was here")
      expect(described_class.logger).to receive(:info).with "mario was here"
      expect(described_class.logger).to receive(:info).with "another message"
      subject
    end

    it "should create a new analytics object with the analytics attributes" do
      analytics_class = described_class.instance_variable_get(:@analytics_class)
      expect(analytics_class).to receive(:create).with analytics_attrs
      subject
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
        expect(described_class).to receive(:notify_event_outcome).with(invalid_event, {heads: 10}) { notify_failure }
        described_class.perform "event", {heads: 10}
      end
    end
  end

  describe "self.analytics_attrs(event_type, data)" do
    subject { described_class.analytics_attrs(event_type, some_data) }

    before { allow(Time.zone).to receive(:now) { time_now }}

    it "should return an array of required attributes by default" do
      expect(subject).to eq(analytics_attrs)
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

  describe "self.inheritable_attributes" do
    let(:expected_attrs) {[
      :queue,
      :event_name,
      :analytics_class,
      :backoff_strategy,
      :start_message,
      :success_message,
      :failure_message
    ]}

    it "should have a list of inheritable attributes" do
      expect(described_class.inheritable_attributes).to eq(expected_attrs)
    end
  end
end
