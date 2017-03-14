RSpec.describe LoginEventLogger, type: :event_logger do
  subject { described_class.new }

  it "includes EventLogger::Enqueue" do
    expect(subject).to respond_to(:enqueue_in_with_fallback)
  end

  it "has an #event_type" do
    expect(subject.event_type).to eq "login"
  end

  it "inherits from the ApplicationEventLogger" do
    expect(described_class.superclass).to eq ApplicationEventLogger
  end

  describe ".perform" do
    let(:result) { described_class.perform("login", data) }
    let(:data) { { some: "info" } }
    let(:performer) { double(LoginEventPerformer).as_null_object }
    let(:logger) { Logger.new Tempfile.new("logger") }

    before do
      allow(LoginEventPerformer).to receive(:new) { performer }
      allow(described_class).to receive(:logger) { logger }
    end

    it "logs some messages" do
      expect(logger).to receive(:info).with \
        "Starting LoginEventLogger with data #{data}"
      expect(logger).to receive(:info).with performer
      result
    end

    it "builds a new LoginEventPerformer" do
      expect(LoginEventPerformer).to receive(:new).with({ data: data }, logger)
      result
    end

    it "performs the new LoginEventPerformer" do
      expect(performer).to receive(:perform)
      result
    end
  end
end
