describe API::UsersController do
  let(:course) { build_stubbed :course }

  before(:each) do
    login_user current_user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an admin" do
    let(:current_user) { build_stubbed :user, courses: [course], role: :admin }

    describe "GET search" do
      it "returns a Bad Request status if there is no email or name param" do
        get :search, format: :json
        expect(response).to have_http_status :bad_request
      end

      context "when the user exists" do
        let!(:user) { create :user, first_name: "James", last_name: "Bond", email: "007@secretservice.com" }

        it "returns the student if found using email" do
          get :search, params: { email: "007@secretservice.com" }, format: :json
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end

        it "returns the student if found using their name" do
          get :search, params: { first_name: "James", last_name: "Bond" }, format: :json
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end
      end

      context "when the user does not exist" do
        it "returns a Not Found status if no such user exists" do
          get :search, params: { email: "006@secretservice.com" }, format: :json
          expect(response).to have_http_status :not_found
        end
      end
    end
  end

  context "as a student" do
    let(:current_user) { build_stubbed :user, courses: [course], role: :student }

    describe "GET search" do
      it "redirects to root" do
        get :search, format: :json
        expect(response).to have_http_status 302
      end
    end
  end
end
