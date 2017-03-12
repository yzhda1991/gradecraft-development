describe Services::Actions::UpdatesUser do
  let(:user) { create :user }
  let(:attributes) { user.attributes.symbolize_keys }

  it "expects the user to update" do
    expect { described_class.execute attributes: attributes }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to the user" do
    expect { described_class.execute user: user }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "updates the user with the new attributes" do
    attributes.merge!(first_name: "Gary")
    result = described_class.execute attributes: attributes, user: user
    expect(result[:user].first_name).to eq "Gary"
  end

  it "halts if the user is invalid" do
    attributes.merge!(first_name: nil)
    expect { described_class.execute attributes: attributes, user: user }.to \
      raise_error LightService::FailWithRollbackError
  end
end
