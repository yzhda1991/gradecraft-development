describe Services::Actions::ActivatesUser do
  let(:user) { build :user, password: nil, internal: true }

  it "expects a user to activate" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "activates the user if they are internal" do
    result = described_class.execute user: user
    expect(result[:user]).to be_activated
  end

  it "activates the user if specified" do
    result = described_class.execute user: user, manually_activate: true
    expect(result[:user]).to be_activated
  end
end
