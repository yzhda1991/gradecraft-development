require "active_record_spec_helper"
require "./app/services/creates_or_updates_user_from_lti"

describe Services::CreatesOrUpdatesUserFromLTI, focus: true do
  let(:auth_hash) { OmniAuth::AuthHash.new({
    extra: {
      raw_info: {
        lis_person_contact_email_primary: "john.doe@umich.edu",
        lis_person_sourcedid: "johndoe",
        lis_person_name_given: "john",
        lis_person_name_family: "doe",
        context_id: "cosc111",
        context_label: "111",
        context_title: "Intro to Computery Things"
      }
    }})
  }

  describe ".create_or_update" do
    it "parses user attributes from the auth hash" do
      expect(Services::Actions::ParseUserAttributesFromAuthHash).to receive(:execute).and_call_original
      described_class.create_or_update auth_hash
    end

    it "parses course attributes from the auth hash" do
      expect(Services::Actions::ParseCourseAttributesFromAuthHash).to receive(:execute).and_call_original
      described_class.create_or_update auth_hash
    end

    it "decides if a user gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesUser).to receive(:execute).and_call_original
      described_class.create_or_update auth_hash
    end

    it "decides if a course gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesCourseByUID).to receive(:execute).and_call_original
      described_class.create_or_update auth_hash
    end

    describe "context failures" do
      it "is pending tests"
    end
  end
end
