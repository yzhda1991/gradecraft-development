describe Services::Actions::GeneratesPassword do
  let(:user) { build :user, password: nil }

  it "expects a user to generate a password for" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "generates a password for the user" do
    result = described_class.execute user: user
    expect(result[:user].password).to_not be_nil
  end

  it "does not generate a password if the user is internal" do
    user.internal = true
    result = described_class.execute user: user
    expect(result[:user].password).to be_nil
  end
end
