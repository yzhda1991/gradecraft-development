describe Services::Actions::RetrievesLMSUsers do
  let(:access_token) { "TOKEN" }
  let(:provider) { "canvas" }
  let(:user_ids) { ["USER_1", "USER_2"] }

  before do
    # do not call the API
    allow_any_instance_of(ActiveLMS::Syllabus).to receive(:user).and_return({})
  end

  it "expects the provider to retrieve the users from" do
    expect { described_class.execute access_token: access_token, user_ids: user_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the access token to use to retrieve the users" do
    expect { described_class.execute provider: provider, user_ids: user_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the provider's user ids to retrieve the users from" do
    expect { described_class.execute provider: provider, access_token: access_token }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the imported users" do
    result = described_class.execute provider: provider, access_token: access_token,
      user_ids: user_ids
    expect(result).to have_key :users
  end

  it "retrieves the user details from the lms provider" do
    expect(ActiveLMS::Syllabus).to \
      receive(:new).with(provider, access_token).and_call_original

    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:user).with(user_ids.first)
        .and_return({})

    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:user).with(user_ids.last)
        .and_return({})

    described_class.execute provider: provider, access_token: access_token,
      user_ids: user_ids
  end
end
