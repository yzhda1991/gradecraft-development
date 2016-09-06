require "active_record_spec_helper"
require "./app/services/imports_lms_assignments"

describe Services::ImportsLMSAssignments do
  let(:access_token) { "TOKEN" }
  let(:provider) { :canvas }

  describe ".import" do
    let(:assignment_ids) { ["ASSIGNMENT_1", "ASSIGNMENT_2"] }
    let(:assignment_type) { create :assignment_type, course: course }
    let(:course) { create :course }
    let(:course_id) { "COURSE_ID" }

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

  describe ".refresh" do
    let(:assignment) { create :assignment }

    it "retrieves the imported assignment from the database" do
      expect(Services::Actions::RetrievesImportedAssignment).to \
        receive(:execute).and_call_original

      described_class.refresh provider, access_token, assignment
    end

    xit "retrieves the assignment details from the lms provider"
    xit "updates the assignment details in the database"
  end
end

