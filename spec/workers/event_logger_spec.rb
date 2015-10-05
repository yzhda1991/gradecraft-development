require 'spec_helper'

# PageviewEventLogger.new(pageview_logger_attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe EventLogger, type: :background_job do
  describe "self.perform" do
    it "should print the @start_message class instance variable to the log" do
      EventLogger.instance_variable_set(:@start_message, "some message")
      expect(EventLogger).to receive(:p).with("some message")
      EventLogger.perform "event"
    end

    it "should create a new analytics event using the event attrs" do
    end

    it "should notify the event outcome to the log" do
    end
  end
end
