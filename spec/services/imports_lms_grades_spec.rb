describe Services::ImportsLMSGrades do
  describe ".call" do
    let(:access_token) { "TOKEN" }
    let(:assignment) { create :assignment }
    let(:assignment_ids) { ["ASSIGNMENT_1"] }
    let(:course_id) { "COURSE_ID" }
    let(:grade_ids) { ["GRADE_1", "GRADE_2"] }
    let(:provider) { :canvas }
    let(:user) { create :user }

    before do
      # do not call the API
      allow_any_instance_of(ActiveLMS::Syllabus).to receive(:grades).and_return({ grades: [] })
    end

    it "retrieves the grade details from the lms provider" do
      expect(Services::Actions::RetrievesLMSGrades).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, assignment_ids,
        grade_ids, assignment, user
    end

    it "retrieves the user details from the lms provider" do
      expect(Services::Actions::RetrievesLMSUsers).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, assignment_ids,
        grade_ids, assignment, user
    end

    it "imports the users" do
      expect(Services::Actions::ImportsLMSUsers).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, assignment_ids,
        grade_ids, assignment, user
    end

    it "imports the grades" do
      expect(Services::Actions::ImportsLMSGrades).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, assignment_ids,
        grade_ids, assignment, user
    end

    it "enqueues the grade updater jobs" do
      expect(Services::Actions::EnqueuesGradeUpdaterJobs).to \
        receive(:execute).and_call_original

      described_class.call provider, access_token, course_id, assignment_ids,
        grade_ids, assignment, user
    end
  end
end
