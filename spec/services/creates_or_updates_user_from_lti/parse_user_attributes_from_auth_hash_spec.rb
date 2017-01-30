require "light-service"
require "./app/services/creates_or_updates_user_from_lti/parse_user_attributes_from_auth_hash"

describe Services::Actions::ParseUserAttributesFromAuthHash do
  let(:auth_hash) { OmniAuth::AuthHash.new({
    extra: {
      raw_info: {
        lis_person_contact_email_primary: "john.doe@umich.edu",
        lis_person_sourcedid: "johndoe",
        lis_person_name_given: "john",
        lis_person_name_family: "doe"
      }
    }})
  }

  it "expects an auth hash" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the user attributes" do
    result = described_class.execute auth_hash: auth_hash
    expect(result).to have_key :user_attributes
  end
end
