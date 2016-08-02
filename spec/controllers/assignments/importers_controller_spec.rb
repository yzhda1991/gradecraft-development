require "rails_spec_helper"
require "./app/services/imports_lms_assignments"

<<<<<<< 368bab70ccf3bc351f92be8e9bccab10142da169:spec/controllers/assignments/importers_controller_spec.rb
describe Assignments::ImportersController do
=======
describe ImportersController do
  let(:course) { create :course }
  let(:professor) { professor_membership.user }
  let(:professor_membership) { create :professor_course_membership, course: course }
  let(:provider) { :canvas }

  describe "GET courses" do
    context "as a professor" do
      before { login_user(professor) }

      context "without an existing authentication" do
        it "redirects to authorize with canvas" do
          get :courses, importer_id: provider

          expect(response).to redirect_to "/auth/canvas"
        end
      end
    end
  end

>>>>>>> Require that the user be authenticated before interacting with canvas:spec/controllers/importers_controller_spec.rb
  describe "POST assignments_import" do
    let(:course_id) { "COURSE_ID" }

    context "as a professor" do
      let(:access_token) { "BLAH" }
      let(:assignment_ids) { [{ "name" => "Assignment 1" }] }
      let(:assignment_type) { create :assignment_type }
      let(:result) { double(:result, success?: true, message: "") }
      let!(:user_authorization) do
        create :user_authorization, :canvas, user: professor, access_token: access_token
      end

      before do
        ENV["CANVAS_ACCESS_TOKEN"] = access_token
        login_user(professor)
        allow(controller).to receive(:current_course).and_return course
        allow(Services::ImportsLMSAssignments).to receive(:import).and_return result
      end

      it "imports the selected assignments" do
        expect(Services::ImportsLMSAssignments).to \
          receive(:import).with(provider.to_s, access_token, course_id,
                                assignment_ids, course, assignment_type.id.to_s)
                          .and_return result

        post :assignments_import, importer_provider_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id
      end

      it "renders the results" do
        post :assignments_import, importer_provider_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id

        expect(response).to render_template :assignments_import_results
      end

      context "with an invalid request" do
        it "re-renders the template with the error" do
          allow(result).to receive(:success?).and_return false
          syllabus = double(course: {}, assignments: [])
          allow(controller).to receive(:syllabus).and_return syllabus

          post :assignments_import, importer_provider_id: provider, id: course_id,
            assignment_ids: assignment_ids, assignment_type_id: assignment_type.id

          expect(response).to render_template :assignments
        end
      end
    end

    context "as a student" do
      it "redirects to the root url" do
        post :assignments_import, importer_provider_id: provider, id: course_id

        expect(response).to redirect_to root_path
      end
    end
  end
end
