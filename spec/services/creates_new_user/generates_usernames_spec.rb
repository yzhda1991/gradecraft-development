describe Services::Actions::GeneratesUsernames do
  let(:user) { build :user, email: "blah@example.com", password: nil, username: "bleh", internal: true }

  it "expects a user to set usernames for" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "sets the kerberos id to the username" do
    result = described_class.execute user: user
    expect(result[:user].kerberos_uid).to eq user.username
  end

  it "creates the username from the email address" do
    user.username = nil
    result = described_class.execute user: user
    expect(result[:user].username).to eq "blah"
  end

  it "creates the email address from the username" do
    user.email = nil
    result = described_class.execute user: user
    expect(result[:user].email).to eq "bleh@umich.edu"
  end
end
