require "./app/services/imports_lms_users"

describe Services::ImportsLMSUsers do
  describe ".import" do
    let(:access_token) { "TOKEN" }
    let(:course_id) { "COURSE_ID" }
    let(:course) { build :course }
    let(:provider) { :canvas }
    let(:users) { { "id" => "USER_1",
                     "primary_email" => "jimmy@example.com",
                     "name" => "Jimmy Page" } }

    before do
      # do not call the API
      allow_any_instance_of(ActiveLMS::Syllabus).to receive(:users).and_return users
    end

    it "retrieves the users from the lms provider" do
      expect(Services::Actions::RetrievesLMSUsers).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, course
    end

    it "imports the users from the lms provider" do
      expect(Services::Actions::ImportsLMSUsers).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, course
    end
  end
end
