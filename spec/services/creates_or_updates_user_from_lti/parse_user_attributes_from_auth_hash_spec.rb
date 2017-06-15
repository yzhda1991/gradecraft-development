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

  it "fails the context if the auth hash is invalid" do
    auth_hash.extra.raw_info.lis_person_name_given = nil
    auth_hash.extra.raw_info.lis_person_name_family = nil
    result = described_class.execute auth_hash: auth_hash
    expect(result.success?).to be_falsey
  end

  it "passes if the context of the auth hash is valid given the full name has one word" do
    auth_hash.extra.raw_info.lis_person_name_given = nil
    auth_hash.extra.raw_info.lis_person_name_family = nil
  auth_hash.extra.raw_info.lis_person_name_full = "Shakira"
    result = described_class.execute auth_hash: auth_hash
    expect(result.success?).to be_truthy
    expect(result.user_attributes[:first_name]).to eq "Shakira"
    expect(result.user_attributes[:last_name]).to eq "Shakira"
  end

  it "passes if the context of the auth hash is valid given the full name has two words" do
    auth_hash.extra.raw_info.lis_person_name_given = nil
    auth_hash.extra.raw_info.lis_person_name_family = nil
    auth_hash.extra.raw_info.lis_person_name_full = "Samus Aran"
    result = described_class.execute auth_hash: auth_hash
    expect(result.success?).to be_truthy
    expect(result.user_attributes[:first_name]).to eq "Samus"
    expect(result.user_attributes[:last_name]).to eq "Aran"
  end

  it "passes if the context of the auth hash is valid given the full name has three words" do
    auth_hash.extra.raw_info.lis_person_name_given = nil
    auth_hash.extra.raw_info.lis_person_name_family = nil
    auth_hash.extra.raw_info.lis_person_name_full = "Dirk The Daring"
    result = described_class.execute auth_hash: auth_hash
    expect(result.success?).to be_truthy
    expect(result.user_attributes[:first_name]).to eq "Dirk The"
    expect(result.user_attributes[:last_name]).to eq "Daring"
  end
end
