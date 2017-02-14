require "active_record_spec_helper"
require "./app/services/creates_or_updates_course_from_lti"

describe Services::CreatesOrUpdatesCourseFromLTI do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
    {
      extra: {
        raw_info: {
          context_id: "cosc111",
          context_label: "111",
          context_title: "Intro to Computery Things"
        }
      }
    })
  end

  describe ".create_or_update" do
    it "parses user attributes from the auth hash" do
      expect(Services::Actions::ParseCourseAttributesFromAuthHash).to receive(:execute).and_call_original
      described_class.create_or_update auth_hash
    end

    it "decides if a user gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesCourseByUID).to receive(:execute).and_call_original
      result = described_class.create_or_update auth_hash
    end
  end
end
