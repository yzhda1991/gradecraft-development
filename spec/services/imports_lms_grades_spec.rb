require "active_record_spec_helper"
require "./app/services/imports_lms_grades"

describe Services::ImportsLMSGrades do
  describe ".import" do
    let(:access_token) { "TOKEN" }
    let(:assignment) { create :assignment }
    let(:course_id) { "COURSE_ID" }
    let(:grade_ids) { ["GRADE_1", "GRADE_2"] }
    let(:provider) { :canvas }

    it "retrieves the grade details from the lms provider" do
      expect(Services::Actions::RetrievesLMSGrades).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, grade_ids, assignment.id
    end

    it "imports the grades" do
      expect(Services::Actions::ImportsLMSGrades).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, grade_ids, assignment.id
    end
  end
end
