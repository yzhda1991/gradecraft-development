describe API::UsersController do
  let(:course) { build_stubbed :course }

  before(:each) do
    login_user current_user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an admin" do
    let(:current_user) { build_stubbed :user, courses: [course], role: :admin }

    describe "GET search" do
      let!(:user) { create :user, first_name: "James", last_name: "Bond", username: "james.bond", email: "007@secretservice.com" }

      it "returns a Bad Request status if there is no search criteria" do
        get :search, format: :json
        expect(response).to have_http_status :bad_request
      end

      context "with unique search terms" do
        it "returns the user if found using email" do
          get :search, params: { email: "007@secretservice.com" }, format: :json
          expect(assigns(:users)).to eq [user]
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end

        it "returns the user if found using their username" do
          get :search, params: { username: "james.bond" }, format: :json
          expect(assigns(:users)).to eq [user]
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end
      end

      context "with non-unique search terms" do
        let!(:another_user) { create :user, first_name: "James", last_name: "Bond", username: "j.bond", email: "james.bond@umich.edu" }

        it "returns the users if found using their full name" do
          get :search, params: { first_name: "James", last_name: "Bond" }, format: :json
          expect(assigns(:users)).to match_array [user, another_user]
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end

        it "returns the users if found using their first name" do
          get :search, params: { first_name: "James" }, format: :json
          expect(assigns(:users)).to match_array [user, another_user]
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end

        it "returns the users if found using their last name" do
          get :search, params: { last_name: "Bond" }, format: :json
          expect(assigns(:users)).to match_array [user, another_user]
          expect(response).to have_http_status :ok
          expect(response).to render_template :search
        end
      end

      it "returns a Not Found status if no matching users are found" do
        get :search, params: { email: "006@secretservice.com" }, format: :json
        expect(response).to have_http_status :not_found
      end
    end
  end

  context "as a student" do
    let(:current_user) { build_stubbed :user, courses: [course], role: :student }

    describe "GET search" do
      it "redirects" do
        get :search, format: :json
        expect(response).to have_http_status 302
      end
    end
  end
end
