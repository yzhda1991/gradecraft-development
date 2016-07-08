require "active_record_spec_helper"
require "./app/services/imports_lms_assignments"

describe Services::ImportsLMSAssignments do
  describe ".import" do
    let(:access_token) { "TOKEN" }
    let(:assignment_ids) { ["ASSIGNMENT_1", "ASSIGNMENT_2"] }
    let(:assignment_type) { create :assignment_type, course: course }
    let(:course) { create :course }
    let(:course_id) { "COURSE_ID" }
    let(:provider) { :canvas }

    before do
      # do not call the API
      allow_any_instance_of(ActiveLMS::Syllabus).to receive(:assignments).and_return []
    end

    it "retrieves the assignment details from the lms provider" do
      expect(Services::Actions::RetrievesLMSAssignments).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, assignment_ids, course,
        assignment_type.id
    end

    it "imports the assignments" do
      expect(Services::Actions::ImportsLMSAssignments).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, assignment_ids, course,
        assignment_type.id
    end
  end
end

