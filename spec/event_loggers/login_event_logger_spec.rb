require "active_record_spec_helper"

RSpec.describe LoginEventLogger, type: :event_logger do
  subject { described_class }

  it "includes EventLogger::Enqueue" do
  end
end
