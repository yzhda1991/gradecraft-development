require_relative "../../../lib/event_logger/base"
require_relative "../../../lib/analytics/event"
require_relative "../../../lib/inheritable_ivars"
require_relative "../../../lib/loggly_resque"
require_relative "../../support/test_classes/lib/event_logger/" \
  "logger_base_test_class"

describe EventLogger::Base, type: :vendor_library do
  subject { described_class.new }

  let(:logger) { Logger.new Tempfile.new('logfile') }
  let(:time_now) { Date.parse("Jun 20 1942").to_time }

  before do
    allow(described_class).to receive(:logger) { logger }
  end

  it "defaults to the :event_logger queue" do
    expect(described_class.queue).to eq :event_logger
  end

  describe "inclusions" do
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
  end

  describe "a class instance" do
    it "has base attributes" do
      allow(Time).to receive(:now) { time_now }

      expect(subject.base_attrs).to eq({
        event_type: subject.event_type,
        created_at: time_now
      })
    end

    it "has an event type" do
      allow(subject).to receive(:class) { LoggerBaseTestClass }
      expect(subject.event_type).to eq "logger_base_test_class"
    end
  end

  describe "class-level behaviors" do
    subject { described_class }

    it "has a readable queue" do
      expect(subject.queue).to eq :event_logger
    end

    it "has an EventName" do
      expect(subject.event_name).to eq subject.queue.to_s.camelize
    end

    describe ".perform" do
      let(:result) { subject.perform(event_type, data) }
      let(:event_type) { "waffle" }
      let(:data) { { some: "new weird data" } }

      before do
        allow(subject).to receive(:event_outcome_message) { "some outcome" }
      end

      it "logs messages on start and complete" do
        expect(logger).to receive(:info).with \
          "Starting #{subject.event_name} with data #{data}"
        expect(logger).to receive(:info).with "some outcome"
        result
      end

      it "creates an analytics event with the .analytics_class" do
        allow(subject).to receive(:analytics_class) { Analytics::LoginEvent }
        expect(Analytics::LoginEvent).to receive(:create)
          .with data.merge(event_type: "waffle")
        result
      end
    end

    describe ".backoff_strategy" do
      let(:result) { subject.backoff_strategy }
      let(:backoff_strategy) { double(:backoff_strategy).as_null_object }

      before do
        allow(EventLogger).to receive_message_chain(:configuration, \
          :backoff_strategy) { backoff_strategy }
      end

      it "uses the backoff strategy from the EventLogger configuration" do
        expect(result).to eq(backoff_strategy)
      end

      it "caches the backoff strategy" do
        result
        expect(EventLogger).not_to receive(:configuration)
        result
      end

      it "sets the result to @backoff_strategy" do
        result
        expect(subject.instance_variable_get(:@backoff_strategy))
          .to eq backoff_strategy
      end
    end

    describe ".event_outcome_message(event, data)" do
      let!(:valid_event) { Analytics::Event.new }
      let!(:invalid_event) { Analytics::Event.new }

      before(:each) do
        allow(valid_event).to receive(:valid?).and_return true
        allow(invalid_event).to receive(:valid?).and_return false
        allow(subject).to receive_messages(
          logger: logger,
          success_message: "great stuff happened",
          failure_message: "bad stuff happened"
        )
      end

      context "the event is valid" do
        let(:notify_success) { "great stuff happened with data {:heads=>5}" }

        it "should output the @success_message" do
          allow(Analytics::Event).to receive(:create) { valid_event }
          expect(subject).to receive(:event_outcome_message)
            .with(valid_event, {heads: 5}) { notify_success }
          subject.perform "event", {heads: 5}
        end
      end

      context "the event is not valid" do
        let(:notify_failure) { "bad stuff happened with data {:heads=>10}" }

        it "should output the @failure_message" do
          allow(Analytics::Event).to receive(:create) { invalid_event }
          expect(subject).to receive(:event_outcome_message)
            .with(invalid_event, {heads: 10}) { notify_failure }
          subject.perform "event", {heads: 10}
        end
      end
    end

    it "should have a list of inheritable attributes" do
      expect(subject.inheritable_ivars).to eq [:queue]
    end
  end
end
