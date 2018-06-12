describe Assignments::ImportersController do
  let(:course) { build :course }
  let(:professor) { create :user, courses: [course], role: :professor }
  let(:assignment) { create :assignment, course: course }
  let(:provider) { :canvas }
  let(:course_id) { "COURSE_ID" }

  before { allow(controller).to receive(:current_course).and_return course }

  context "as a professor" do
    let(:access_token) { "BLAH" }
    let(:result) { double :result, success?: true, message: "" }
    let!(:user_authorization) do
      create :user_authorization, :canvas, user: professor, access_token: access_token,
        expires_at: 2.days.from_now
    end

    before do
      login_user professor
      allow(Services::ImportsLMSAssignments).to receive(:import).and_return result
    end

    describe "GET show" do
      it "renders the correct template if the importer provider id is allowed" do
        get :show, params: { provider_id: :csv }
        expect(response).to render_template :csv
      end

      it "redirects to index if the importer provider id is not allowed" do
        get :show, params: { provider_id: :app }
        expect(response).to redirect_to action: :index
      end
    end

    describe "GET download" do
      it "returns sample csv data" do
        get :download, params: { importer_provider_id: :csv }, format: :csv
        expect(response.body).to \
          include("Assignment Name", "Assignment Type", "Point Total", "Description",
            "Due Date (mm/dd/yyyy hh:mm:ss am/pm)")
      end
    end

    describe "GET assignments" do
      let(:syllabus) { double :syllabus, course: {}, assignments: [] }

      before(:each) do
        allow(ActiveLMS::Syllabus).to receive(:new).with("canvas", access_token).and_return \
          syllabus
      end
    end

    describe "POST assignments_import" do
      let(:assignment_ids) { ["123", "456"] }
      let(:assignment_type) { build_stubbed :assignment_type }
      let(:syllabus) { double(course: {}, assignments: []) }

      before(:each) do
        allow(ActiveLMS::Syllabus).to receive(:new).with("canvas", access_token).and_return \
          syllabus
      end

      it "links the provider credentials if the provider is canvas" do
        expect_any_instance_of(CanvasAuthorization).to receive(:link_canvas_credentials)
        post :assignments_import, params: { importer_provider_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id }
      end

      it "links the provider credentials if the provider is canvas" do
        expect_any_instance_of(CanvasAuthorization).to receive(:link_canvas_credentials)
        post :assignments_import, params: { importer_provider_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id }
      end

      it "imports the selected assignments" do
        expect(Services::ImportsLMSAssignments).to \
          receive(:import).with(provider.to_s, access_token, course_id,
                                assignment_ids, course, assignment_type.id.to_s)
                          .and_return result

        post :assignments_import, params: { importer_provider_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id }
      end

      it "renders the results" do
        post :assignments_import, params: { importer_provider_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id }

        expect(response).to render_template :assignments_import_results
      end

      context "with an invalid request" do
        it "re-renders the template with the error" do
          allow(result).to receive(:success?).and_return false

          post :assignments_import, params: { importer_provider_id: provider,
            id: course_id, assignment_ids: assignment_ids,
            assignment_type_id: assignment_type.id }

          expect(response).to render_template :assignments
        end
      end
    end

    describe "POST #refresh_assignment" do
      it "links the provider credentials if the provider is canvas" do
        expect_any_instance_of(CanvasAuthorization).to receive(:link_canvas_credentials)
        post :refresh_assignment, params: { importer_provider_id: provider,
                                            id: assignment.id }
      end

      it "updates the assignment from the provider details" do
        expect(Services::ImportsLMSAssignments).to \
          receive(:refresh).with(provider.to_s, access_token, assignment).and_return result

        post :refresh_assignment, params: { importer_provider_id: provider,
                                            id: assignment.id }
      end

      it "redirects back to the assignment show view and displays a notice" do
        allow(Services::ImportsLMSAssignments).to receive(:refresh).and_return result

        post :refresh_assignment, params: { importer_provider_id: provider,
                                            id: assignment.id }

        expect(response).to redirect_to assignment_path(assignment)
        expect(flash[:notice]).to \
          eq "You have successfully updated #{assignment.name} from Canvas"
      end

      context "for an assignment that was not imported" do
        it "redirects back to the assignment show view and displays an alert" do
          allow(result).to receive_messages(success?: false,
                                            message: "This was not imported")
          allow(Services::ImportsLMSAssignments).to receive(:refresh).and_return result

          post :refresh_assignment, params: { importer_provider_id: provider,
                                              id: assignment.id }

          expect(response).to redirect_to assignment_path(assignment)
          expect(flash[:alert]).to eq "This was not imported"
        end
      end
    end

    describe "POST #update_assignment" do
      it "links the provider credentials if the provider is canvas" do
        expect_any_instance_of(CanvasAuthorization).to receive(:link_canvas_credentials)
        post :update_assignment, params: { importer_provider_id: provider, id: assignment.id }
      end

      it "updates the canvas assignment from the assignment details" do
        expect(Services::ImportsLMSAssignments).to \
          receive(:update).with(provider.to_s, access_token, assignment).and_return result

        post :update_assignment, params: { importer_provider_id: provider, id: assignment.id }
      end

      it "redirects back to the assignment show view and displays a notice" do
        allow(Services::ImportsLMSAssignments).to receive(:update).and_return result

        post :update_assignment, params: { importer_provider_id: provider, id: assignment.id }

        expect(response).to redirect_to assignment_path(assignment)
        expect(flash[:notice]).to \
          eq "You have successfully updated #{assignment.name} on Canvas"
      end

      context "for an assignment that was not imported" do
        it "redirects back to the assignment show view and displays an alert" do
          allow(result).to receive_messages(success?: false,
                                            message: "This was not updated")
          allow(Services::ImportsLMSAssignments).to receive(:update).and_return result

          post :update_assignment, params: { importer_provider_id: provider, id: assignment.id }

          expect(response).to redirect_to assignment_path(assignment)
          expect(flash[:alert]).to eq "This was not updated"
        end
      end
    end
  end

  context "as a student" do
    let(:student) { create :user, courses: [course], role: :student }

    before(:each) { login_user student }

    describe "POST assignments_import" do
      it "redirects to the root url" do
        post :assignments_import, params: { importer_provider_id: provider, id: course_id }

        expect(response).to redirect_to root_path
      end
    end

    describe "POST #refresh_assignment" do
      it "redirects to the root url" do
        post :refresh_assignment, params: { importer_provider_id: provider,
                                            id: assignment.id }

        expect(response).to redirect_to root_path
      end
    end

    describe "POST #update_assignment" do
      it "redirects to the root url" do
        post :update_assignment, params: { importer_provider_id: provider, id: assignment.id }

        expect(response).to redirect_to root_path
      end
    end
  end
end
