require "rails_spec_helper"
require "./app/services/imports_lms_assignments"

describe ImportersController do
  describe "POST assignments_import" do
    context "as a professor" do
      let(:access_token) { "BLAH" }
      let(:assignment_ids) { [{ "name" => "Assignment 1" }] }
      let(:assignment_type) { create :assignment_type }
      let(:course_id) { "COURSE_ID" }
      let(:course) { create :course }
      let(:professor) { professor_membership.user }
      let(:professor_membership) { create :professor_course_membership, course: course }
      let(:provider) { :canvas }
      let(:result) { double(:result, success?: true) }

      before do
        login_user(professor)
        allow(controller).to receive(:current_course).and_return course
        ENV["CANVAS_ACCESS_TOKEN"] = access_token
      end

      it "imports the selected assignments" do
        expect(Services::ImportsLMSAssignments).to \
          receive(:import).with(provider.to_s, access_token, course_id,
                                assignment_ids, course, assignment_type.id.to_s)
                          .and_return result

        post :assignments_import, importer_id: provider, id: course_id,
          assignment_ids: assignment_ids, assignment_type_id: assignment_type.id
      end

      xit "renders the results"

      context "with an invalid request" do
        xit "re-renders the template with the error"
      end
    end

    context "as a student" do
      xit "redirects to the root url"
    end
  end
end
