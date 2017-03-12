describe IntegrationsController do
  let(:provider) { :canvas }

  context "as a professor" do
    let(:professor) { professor_membership.user }
    let(:professor_membership) { create :course_membership, :professor }

    before { login_user(professor) }

    describe "POST create" do
      context "without an existing authentication" do
        it "redirects to authorize the integration" do
          post :create, params: { integration_id: provider }

          expect(response).to redirect_to "/auth/canvas"
        end
      end

      context "with an expired authentication" do
        let!(:user_authorization) do
          create :user_authorization, :canvas, user: professor,
            access_token: "BLAH", expires_at: 2.days.ago
        end

        it "retrieves a refresh token" do
          expect_any_instance_of(UserAuthorization).to receive(:refresh!)

          post :create, params: { integration_id: provider }
        end
      end

      context "with an existing authentication" do
        let!(:user_authorization) do
          create :user_authorization, :canvas, user: professor,
            access_token: "BLAH", expires_at: 2.days.from_now
        end

        it "redirects to the redirect url" do
          post :create, params: { integration_id: provider }

          expect(response).to redirect_to integration_courses_path(:canvas)
        end
      end
    end
  end

  context "as a student" do
    let(:student) { student_membership.user }
    let(:student_membership) { create :course_membership, :student }

    before { login_user(student) }

    it "redirects to the root" do
      post :create, params: { integration_id: provider }

      expect(response).to redirect_to root_path
    end
  end
end
