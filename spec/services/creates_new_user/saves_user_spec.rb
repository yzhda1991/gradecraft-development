describe Services::Actions::SavesUser do
  let(:user) { build :user, password: nil }

  it "expects a user to save" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "saves the user" do
    result = described_class.execute user: user
    expect(result[:user]).to_not be_new_record
  end

  it "halts if the user is invalid" do
    user.email = nil
    expect { described_class.execute user: user }.to \
      raise_error LightService::FailWithRollbackError
  end
end
