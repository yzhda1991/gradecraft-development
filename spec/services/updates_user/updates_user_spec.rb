require "light-service"
require "active_record_spec_helper"
require "./app/services/updates_user/updates_user"

describe Services::Actions::UpdatesUser do
  let(:user) { create :user }
  let(:attributes) { user.attributes.symbolize_keys }

  it "expects attributes to assign to the user" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "updates the user with the new attributes" do
    attributes.merge!(first_name: "Gary")
    result = described_class.execute attributes: attributes
    expect(result[:user].first_name).to eq "Gary"
  end

  it "halts if the user cannot be found" do
    attributes.merge!(email: "blah@somewhere.com")
    expect { described_class.execute attributes: attributes }.to \
      raise_error LightService::FailWithRollbackError
  end

  it "halts if the user is invalid" do
    attributes.merge!(first_name: nil)
    expect { described_class.execute attributes: attributes }.to \
      raise_error LightService::FailWithRollbackError
  end
end
