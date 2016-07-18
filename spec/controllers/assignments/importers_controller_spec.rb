require "rails_spec_helper"
require "./app/services/imports_lms_assignments"

describe Assignments::ImportersController do
  describe "POST assignments_import" do
    let(:course_id) { "COURSE_ID" }
    let(:provider) { :canvas }

    context "as a professor" do
      let(:access_token) { "BLAH" }
      let(:assignment_ids) { [{ "name" => "Assignment 1" }] }
      let(:assignment_type) { create :assignment_type }
      let(:course) { create :course }
      let(:professor) { professor_membership.user }
      let(:professor_membership) { create :professor_course_membership, course: course }
      let(:result) { double(:result, success?: true, message: "") }

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

        post :assignments_import, importer_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id
      end

      it "renders the results" do
        post :assignments_import, importer_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id

        expect(response).to render_template :assignments_import_results
      end

      context "with an invalid request" do
        it "re-renders the template with the error" do
          allow(result).to receive(:success?).and_return false
          syllabus = double(course: {}, assignments: [])
          allow(controller).to receive(:syllabus).and_return syllabus

          post :assignments_import, importer_id: provider, id: course_id,
            assignment_ids: assignment_ids, assignment_type_id: assignment_type.id

          expect(response).to render_template :assignments
        end
      end
    end

    context "as a student" do
      it "redirects to the root url" do
        post :assignments_import, importer_id: provider, id: course_id

        expect(response).to redirect_to root_path
      end
    end
  end
end
