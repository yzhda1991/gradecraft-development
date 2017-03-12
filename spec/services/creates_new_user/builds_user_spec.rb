describe Services::Actions::BuildsUser do
  let(:user) { build :user }
  let(:attributes) { user.attributes }

  it "expects attributes to assign to the user" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the built user" do
    result = described_class.execute attributes: attributes
    expect(result).to have_key :user
  end
end
