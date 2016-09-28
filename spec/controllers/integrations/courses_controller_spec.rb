require "rails_spec_helper"

describe Integrations::CoursesController do
  let(:course_id) { "COURSE_ID" }
  let(:provider) { :canvas }

  context "as a professor" do
    let(:course) { create :course }
    let(:professor) { professor_membership.user }
    let(:professor_membership) { create :professor_course_membership, course: course }

    before { login_user(professor) }

    describe "POST #create" do
      context "without an existing authentication" do
        it "redirects to authorize the integration" do
          post :create, { integration_id: provider, id: course_id }

          expect(response).to redirect_to "/auth/canvas"
        end
      end

      context "with an existing authentication" do
        let(:linked_course) { LinkedCourse.last }
        let!(:user_authorization) do
          create :user_authorization, :canvas, user: professor,
            access_token: "BLAH", expires_at: 2.days.from_now
        end

        it "creates the link between the course and the provider course" do
          post :create, { integration_id: provider, id: course_id }

          expect(linked_course).to_not be_nil
          expect(linked_course.provider).to eq provider.to_s
          expect(linked_course.course_id).to eq course.id
          expect(linked_course.provider_resource_id).to eq course_id
          expect(linked_course.last_linked_at).to be_within(1.second).of(DateTime.now)
        end

        it "redirects back to the integrations page" do
          post :create, { integration_id: provider, id: course_id }

          expect(response).to redirect_to integrations_path
        end

        context "with an existing linked course" do
          before do
            LinkedCourse.create! provider: provider, course_id: course.id,
              provider_resource_id: "BLAH"
          end

          it "replaces the current linked course" do
            post :create, { integration_id: provider, id: course_id }

            expect(LinkedCourse.count).to eq 1
            expect(linked_course.course_id).to eq course.id
          end
        end
      end
    end

    describe "DELETE #destroy" do
      context "with an existing authentication" do
        let(:course_id) { "COURSE_1" }
        let!(:linked_course) { LinkedCourse.create provider: provider,
                               course_id: course.id,
                               provider_resource_id: course_id }
        let!(:user_authorization) do
          create :user_authorization, :canvas, user: professor,
            access_token: "BLAH", expires_at: 2.days.from_now
        end

        it "deletes the linked course" do
          delete :destroy, { integration_id: provider, id: course_id }

          expect(LinkedCourse.exists?(linked_course.id)).to be_falsey
        end

        it "redirects back to the integrations page" do
          delete :destroy, { integration_id: provider, id: course_id }

          expect(response).to redirect_to integrations_path
        end
      end
    end
  end

  context "as a student" do
    let(:student) { student_membership.user }
    let(:student_membership) { create :student_course_membership }

    before { login_user(student) }

    it "redirects to the root" do
      post :create, { integration_id: provider, id: course_id }

      expect(response).to redirect_to root_path
    end
  end
end
