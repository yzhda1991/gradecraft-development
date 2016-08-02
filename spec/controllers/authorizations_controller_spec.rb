require "rails_spec_helper"

describe AuthorizationsController do
  describe "GET #create" do
    context "as a professor" do
      let(:canvas_auth_hash) do
        {
          provider: provider,
          credentials: {
            token: "BLAH",
            expires_at: (Time.now + (30 * 24 * 60 * 60)).to_i,
            expires: true
          }
        }.deep_stringify_keys
      end
      let(:professor) { professor_membership.user }
      let(:professor_membership) { create :professor_course_membership }
      let(:provider) { :canvas }

      before do
        request.env["omniauth.auth"] = canvas_auth_hash
        login_user(professor)
      end

      context "for a new authorization" do
        it "creates the authorization for the user and provider" do
          get :create, provider: provider

          authorization = UserAuthorization.unscoped.last

          expect(authorization).to_not be_nil
        end

        it "redirects back to the referrer" do
          session[:return_to] = courses_path

          get :create, provider: provider

          expect(response).to redirect_to courses_path
        end
      end
    end
  end
end
