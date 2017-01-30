require "active_record_spec_helper"
require "./app/services/updates_user_for_course"

describe Services::UpdatesUserForCourse do
  let(:course) { create :course }
  let(:user) { create :user }
  let(:params) { user.attributes.symbolize_keys }

  describe ".update" do
    it "updates the existing user" do
      expect(Services::Actions::UpdatesUser).to receive(:execute).and_call_original
      described_class.update params, course
    end

    it "creates the course membership with the user and course" do
      expect(Services::Actions::CreatesCourseMembership).to receive(:execute).and_call_original
      described_class.update params, course
    end
  end
end
