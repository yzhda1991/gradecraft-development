require 'rails_spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  let(:professor) { create(:professor_course_membership).user }
  let(:student) { create(:student_course_membership).user }

  describe "POST create" do
    describe "authorizations" do
      context"student request" do
        it "redirects the student to the homepage" do
          login_user(student)
          make_request
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe "POST create" do
    let(:submissions_params) {{ assignment_id: "19" }}
    let(:submissions_job_attributes) { submissions_params.merge(professor_id: professor.id) }
    let(:make_request) { get :submissions, submissions_params }

    before { login_user(professor) }

    describe "authorizations" do
      context"student request" do
        it "redirects the student to the homepage" do
          login_user(student)
          make_request
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
