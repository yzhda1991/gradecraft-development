require "rails_spec_helper"

describe Integrations::CoursesController do
  let(:provider) { :canvas }

  context "as a professor" do
    let(:professor) { professor_membership.user }
    let(:professor_membership) { create :professor_course_membership }

    before { login_user(professor) }

    describe "POST #link" do
      context "without an existing authentication" do
        it "redirects to authorize the integration" do
          post :create, { integration_id: provider }

          expect(response).to redirect_to "/auth/canvas"
        end
      end

      xit "creates the link between the course and the provider course"
      xit "redirects back to the integrations page"
    end
  end

  context "as a student" do
    let(:student) { student_membership.user }
    let(:student_membership) { create :student_course_membership }

    before { login_user(student) }

    xit "redirects to the root" do
    end
  end
end
