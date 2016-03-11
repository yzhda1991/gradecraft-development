require_relative "../../../lib/event_logger/base"
require_relative "../../../lib/analytics/event"
require_relative "../../../lib/inheritable_ivars"
require_relative "../../../lib/loggly_resque"

describe EventLogger::Base, type: :vendor_library do
  subject { described_class.new }

  let(:event_type) { "waffle" }
  let(:event_data) { { some: "new weird data" } }
  let(:time_now) { Time.parse "Jun 20 1942" }
  let(:mongoid_event) { double(:mongoid_event) }
  let(:analytics_attrs) do
    { event_type: event_type, created_at: time_now }.merge(event_data)
  end
  let(:logger) { Logger.new(STDOUT) }

  it "includes Resque::Retry" do
    expect(described_class).to respond_to :retry_delay
  end

  it "includes Resque::ExponentialBackoff" do
    expect(described_class).to respond_to :retry_delay_multiplicand_max
  end

  it "includes LogglyResque" do
    expect(described_class).to respond_to :logger_base_url
  end

  it "includes InheritableIvars" do
    expect(described_class).to respond_to :inheritable_instance_variable_names
  end

  describe ".perform" do
    let(:result) { described_class.perform(event_type, event_data) }

    before do
      allow(Time.zone).to receive(:now) { time_now }
      allow(described_class).to receive(:notify_event_outcome)
        .and_return "another message"
      allow(described_class).to receive(:logger) { logger }
    end

    it "should send a start message an event outcome message to the logger" do
      described_class.instance_variable_set(:@start_message, "mario was here")
      expect(described_class.logger).to receive(:info).with "mario was here"
      expect(described_class.logger).to receive(:info).with "another message"
      result
    end

    it "should create a new analytics object with the analytics attributes" do
      analytics_class = described_class.instance_variable_get(:@analytics_class)
      expect(analytics_class).to receive(:create).with analytics_attrs
      result
    end
  end

  describe ".event_outcome_message(event, data)" do
    let!(:valid_event) { Analytics::Event.new }
    let!(:invalid_event) { Analytics::Event.new }

    before(:each) do
      allow(valid_event).to receive(:valid?).and_return true
      allow(invalid_event).to receive(:valid?).and_return false
      allow(described_class).to receive_messages(
        logger: logger,
        success_message: "great stuff happened",
        failure_message: "bad stuff happened"
      )
    end

    context "the event is valid" do
      let(:notify_success) { "great stuff happened with data {:heads=>5}" }

      it "should output the @success_message" do
        allow(Analytics::Event).to receive(:create) { valid_event }
        expect(described_class).to receive(:notify_event_outcome)
          .with(valid_event, {heads: 5}) { notify_success }
        described_class.perform "event", {heads: 5}
      end
    end

    context "the event is not valid" do
      let(:notify_failure) { "bad stuff happened with data {:heads=>10}" }

      it "should output the @failure_message" do
        allow(Analytics::Event).to receive(:create) { invalid_event }
        expect(described_class).to receive(:notify_event_outcome)
          .with(invalid_event, {heads: 10}) { notify_failure }
        described_class.perform "event", {heads: 10}
      end
    end
  end

  it "should have a list of inheritable attributes" do
    expect(described_class.inheritable_ivars).to eq [:queue]
  end
end
