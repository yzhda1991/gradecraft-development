require "active_record_spec_helper"
require "./app/services/imports_lms_grades"

describe Services::ImportsLMSGrades do
  describe ".import" do
    let(:access_token) { "TOKEN" }
    let(:assignment) { create :assignment }
    let(:assignment_ids) { ["ASSIGNMENT_1"] }
    let(:course_id) { "COURSE_ID" }
    let(:grade_ids) { ["GRADE_1", "GRADE_2"] }
    let(:provider) { :canvas }
    let(:user) { create :user }

    before do
      # do not call the API
      allow_any_instance_of(ActiveLMS::Syllabus).to receive(:grades).and_return []
    end

    it "retrieves the grade details from the lms provider" do
      expect(Services::Actions::RetrievesLMSGrades).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, assignment_ids,
        grade_ids, assignment.id, user
    end

    it "imports the grades" do
      expect(Services::Actions::ImportsLMSGrades).to \
        receive(:execute).and_call_original

      described_class.import provider, access_token, course_id, assignment_ids,
        grade_ids, assignment.id, user
    end
  end
end