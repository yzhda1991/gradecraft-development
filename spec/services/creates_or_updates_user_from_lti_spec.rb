require "active_record_spec_helper"
require "./app/services/creates_or_updates_user_from_lti"

describe Services::CreatesOrUpdatesUserFromLTI do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
    {
      extra: {
        raw_info: {
          lis_person_contact_email_primary: "john.doe@umich.edu",
          lis_person_sourcedid: "johndoe",
          lis_person_name_given: "john",
          lis_person_name_family: "doe"
        }
      }
    })
  end

  describe ".create_or_update" do
    it "parses user attributes from the auth hash" do
      expect(Services::Actions::ParseUserAttributesFromAuthHash).to receive(:execute).and_call_original
      described_class.create_or_update auth_hash
    end

    it "decides if a user gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesUser).to receive(:execute).and_call_original
      result = described_class.create_or_update auth_hash
    end
  end
end
