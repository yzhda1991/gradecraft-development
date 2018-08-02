describe "Services::ImportsLMSAssignments" do
  let(:access_token) { "TOKEN" }
  let(:provider) { :canvas }

  describe Services::ImportsLMSAssignments::Import do
    describe ".call" do
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

        described_class.call provider, access_token, course_id, assignment_ids, course,
          assignment_type.id
      end

      it "imports the assignments" do
        expect(Services::Actions::ImportsLMSAssignments).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, course_id, assignment_ids, course,
          assignment_type.id
      end
    end
  end

  describe Services::ImportsLMSAssignments::Refresh do
    let(:assignment) { create :assignment }

    describe ".call" do
      before do
        # do not call the API
        allow_any_instance_of(ActiveLMS::Syllabus).to receive(:assignment).and_return {}
      end

      it "retrieves the imported assignment from the database" do
        expect(Services::Actions::RetrievesImportedAssignment).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, assignment
      end

      it "retrieves the assignment details from the lms provider" do
        expect(Services::Actions::RetrievesLMSAssignment).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, assignment
      end

      it "updates the assignment details in the database" do
        expect(Services::Actions::RefreshAssignment).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, assignment
      end

      it "updates the imported timestamp" do
        expect(Services::Actions::UpdatesImportedTimestamp).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, assignment
      end
    end
  end

  describe Services::ImportsLMSAssignments::Update do
    describe ".call" do
      let(:assignment) { create :assignment }

      before do
        # do not call the API
        allow_any_instance_of(ActiveLMS::Syllabus).to \
          receive(:update_assignment).and_return {}
      end

      it "retrieves the imported assignment from the database" do
        expect(Services::Actions::RetrievesImportedAssignment).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, assignment
      end

      it "updates the assignment details on the provider" do
        expect(Services::Actions::UpdatesLMSAssignment).to \
          receive(:execute).and_call_original

        described_class.call provider, access_token, assignment
      end
    end
  end
end
