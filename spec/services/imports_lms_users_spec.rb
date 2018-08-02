require "./app/services/imports_lms_users"

describe Services::ImportsLMSUsers do
  describe ".call" do
    let(:access_token) { "TOKEN" }
    let(:course_id) { "COURSE_ID" }
    let(:course) { build :course }
    let(:provider) { :canvas }
    let(:user_ids) { [12, 23] }
    let(:users) { { "id" => "USER_1",
                     "primary_email" => "jimmy@example.com",
                     "name" => "Jimmy Page" } }

    before do
      # do not call the API
      allow_any_instance_of(ActiveLMS::Syllabus).to receive(:users).and_return users
    end

    it "retrieves the users from the lms provider" do
      expect(Services::Actions::RetrievesLMSUsersWithRoles).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, user_ids, course
    end

    it "imports the users from the lms provider" do
      expect(Services::Actions::ImportsLMSUsers).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, user_ids, course
    end
  end
end
