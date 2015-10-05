require 'spec_helper'

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe EventLogger, type: :background_job do
  describe "self.perform" do
    before do
      @now = Time.parse "Oct 20 1985"
      @mongoid_event = double(:mongoid_event)
      allow(EventLogger).to receive(:notify_event_outcome).and_return double(:mongoid_event, valid?: true)
    end

    it "should print the @start_message class instance variable to the log" do
      EventLogger.instance_variable_set(:@start_message, "some message")
      expect(EventLogger).to receive(:p).with("some message")
      EventLogger.perform "event"
    end

    it "should create a new analytics event using the event attrs" do
      allow(EventLogger).to receive_messages(event_type: "event", data: {created_at: @now})
      expect(Analytics::Event).to receive(:create).with EventLogger.event_attrs("event", {created_at: @now})
      EventLogger.perform "event", created_at: @now
    end

    it "should notify the event outcome to the log" do
      allow(Analytics::Event).to receive_messages(create: @mongoid_event)
      expect(EventLogger).to receive(:notify_event_outcome).with @mongoid_event
      EventLogger.perform "event"
    end
  end

  describe "self.notify_event_outcome(event)" do
    context "the event is valid" do
      it "should output the @success_message" do
        EventLogger.instance_variable_set(:@success_message, "great stuff happened")
        expect(EventLogger).to receive(:puts).with("great stuff happened")
        EventLogger.notify_event_outcome double(:event, valid?: true)
      end
    end

    context "the event is not valid" do
      it "should output the @failure_message" do
        EventLogger.instance_variable_set(:@failure_message, "bad stuff happened")
        expect(EventLogger).to receive(:puts).with("bad stuff happened")
        EventLogger.notify_event_outcome double(:event, valid?: false)
      end
    end
  end

  describe "self.event_attrs(event_type, data)" do
    before do
      @now = Time.parse "Jun 20 1942"
      @base_attrs = { event_type: "waffle", created_at: @now }
    end

    it "should return an array of required attributes by default" do
      expect(EventLogger).to receive(:event_attrs).and_return @base_attrs
      allow(Time).to receive_messages(now: @now)
      EventLogger.event_attrs("waffle")
    end

    it "should merge the options in the data hash" do
      @later = Time.parse "Jan 9 2055"
      expect(EventLogger).to receive(:event_attrs).and_return @base_attrs.merge(created_at: @later)
      EventLogger.event_attrs("waffle", created_at: @later)
    end
  end
end
