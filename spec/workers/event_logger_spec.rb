require 'spec_helper'

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe EventLogger, type: :background_job do
  describe "self.perform" do
    before do
      @now = Time.parse "Oct 20 1985"
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
      @mongoid_event = double(:mongoid_event)
      allow(Analytics::Event).to receive_messages(create: @mongoid_event)
      expect(EventLogger).to receive(:notify_event_outcome).with @mongoid_event
      EventLogger.perform "event"
    end
  end
end
