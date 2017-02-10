require "active_record_spec_helper"
require "./app/services/creates_course_membership"

describe Services::CreatesCourseMembership do
  let(:course) { create :course }
  let(:user) { create :user }

  describe ".create" do
    it "creates the course membership" do
      expect(Services::Actions::CreatesCourseMembership).to receive(:execute).and_call_original
      described_class.create user, course
    end
  end
end
