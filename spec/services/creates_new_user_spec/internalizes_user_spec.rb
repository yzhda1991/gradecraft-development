require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_new_user/internalizes_user"

describe Services::Actions::InternalizesUser do
  let(:user) { build :user, password: nil, internal: true }

  it "expects a user to generate a password for" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "sets the kerberos id to the username" do
    result = described_class.execute user: user
    expect(result[:user].kerberos_uid).to eq user.username
  end
end
