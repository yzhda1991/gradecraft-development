require 'logglier'
require_relative '../../../lib/event_logger/base'
require_relative '../../../lib/analytics/event'
require_relative '../../../lib/inheritable_ivars'
require_relative '../../../lib/loggly_resque'
require_relative '../../toolkits/lib/inheritable_ivars/shared_examples'
require_relative '../../toolkits/lib/loggly_resque/shared_examples'
require_relative '../../toolkits/lib/resque_retry/shared_examples'

describe EventLogger::Base, type: :vendor_library do
  include Toolkits::Lib::InheritableIvarsToolkit::SharedExamples
  include Toolkits::Lib::LogglyResqueToolkit::SharedExamples
  include Toolkits::Lib::ResqueRetryToolkit::SharedExamples

  let(:event_type) { "waffle" }
  let(:some_data) {{ some: "new weird data" }}
  let(:time_now) { Time.parse "Jun 20 1942" }
  let(:mongoid_event) { double(:mongoid_event) }
  let(:analytics_attrs) {{ event_type: event_type, created_at: time_now }.merge(some_data) }

  describe "the logger implementation" do
    it_behaves_like "the #logger is implemented through Logglier with LogglyResque", described_class
  end

  describe "self.perform" do
    subject { described_class.perform(event_type, some_data) }

    let(:logger) { double(Logger).as_null_object }

    before do
      allow(Time.zone).to receive(:now) { time_now }
      allow(described_class).to receive(:notify_event_outcome).and_return "another message"
      allow(described_class).to receive(:logger) { logger }
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

  # shared examples for testing that the #backoff_strategy is overridden and
  # included from the target IsConfigurable class. Takes block arguments
  # |target_class, config_class|
  it_behaves_like "it uses a configurable backoff strategy", EventLogger::Base, EventLogger

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
  end

  # test whether @ivars are properly inheritable after extending the
  # InheritableIvars module, pulled in from shared examples in the
  # InheritableIvarsToolit. Defined in:
  # /spec/toolkits/lib/inheritable_ivars/shared_examples
  it_behaves_like "some @ivars are inheritable by subclasses", EventLogger::Base

  describe "self.inheritable_ivars" do
    let(:expected_attrs) {[
      :queue,
      :event_name,
      :analytics_class,
      :start_message,
      :success_message,
      :failure_message
    ]}

    it "should have a list of inheritable attributes" do
      expect(described_class.inheritable_ivars).to eq(expected_attrs)
    end
  end
end
