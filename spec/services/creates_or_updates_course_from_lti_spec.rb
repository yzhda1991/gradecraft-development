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

  describe ".call" do
    it "parses course attributes from the auth hash" do
      expect(Services::Actions::ParseCourseAttributesFromAuthHash).to receive(:execute).and_call_original
      described_class.call auth_hash
    end

    it "decides if a course gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesCourseByUID).to receive(:execute).and_call_original
      result = described_class.call auth_hash
    end

    it "decides if an existing course gets updated if provided" do
      expect(Services::Actions::CreatesOrUpdatesCourseByUID).to receive(:execute).and_call_original
      result = described_class.call auth_hash, false
    end
  end
end
