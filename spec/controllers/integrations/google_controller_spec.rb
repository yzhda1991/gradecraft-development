describe Integrations::GoogleController, type: [:disable_external_api, :controller] do
  include UniMock::StubRails

  let(:user) { build_stubbed :user }
  let(:auth_hash) do
    OmniAuth::AuthHash.new("info" => {
      "first_name" => "Pablo",
      "last_name" => "Picasso",
      "email" => "pablo.picasso@gmail.com"
    })
  end

  describe "#new_user" do
    context "when the environment is beta" do
      before(:each) { stub_env "beta" }

      it "requires that the user be logged in" do
        get :new_user
        expect(response).to have_http_status :redirect
      end

      it "requires external authorization from Google" do
        allow(controller).to receive(:current_user).and_return user
        expect(controller).to receive(:require_authorization_with).with(:google_oauth2)
        get :new_user
      end
    end
    context "when the environment is not beta" do
      before(:each) { stub_env "production" }

      it "redirects to dashboard" do
        get :new_user
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "#auth_callback" do
    before(:each) do
      stub_env "beta"
      allow(controller).to receive_messages \
        require_authorization_with: true,
        auth_hash: auth_hash
      allow(UserAuthorization).to receive(:create_by_auth_hash).and_return true
    end

    context "when the user is logged in" do
      before(:each) { allow(controller).to receive(:current_user).and_return user }

      it "creates a new user authorization" do
        expect(UserAuthorization).to receive(:create_by_auth_hash).with(auth_hash, user).once
        get :auth_callback
      end
    end

    context "when the user is not logged in" do
      context "when the user does not exist" do
        it "creates a new account if the environment is beta" do
          expect{ get :auth_callback }.to change(User, :count).by 1
          expect(User.last).to have_attributes \
            "first_name" => "Pablo",
            "last_name" => "Picasso",
            "email" => "pablo.picasso@gmail.com",
            "username" => "pablo.picasso@gmail.com",
            "activation_state" => "pending"
        end

        it "activates the user if they are inactive and it's specified to activate" do
          get :auth_callback, session: { "activate_google_user" => true }
          expect(User.last).to be_activated
        end

        it "redirects to an error page if the environment is not beta" do
          stub_env "umich"
          get :auth_callback
          expect(response).to redirect_to errors_path(error_type: "account_not_found", status_code: 401)
        end

        it "redirects to the new user page after create" do
          get :auth_callback
          expect(response).to redirect_to action: :new_user
        end
      end

      context "when the user exists" do
        it "automatically logs the user in" do
          user = create :user, email: "pablo.picasso@gmail.com"
          get :auth_callback
          expect(controller.current_user).to eq user
        end

        it "activates the user if they are inactive and it's specified to activate" do
          user = create :user, activated: false, email: "pablo.picasso@gmail.com"
          get :auth_callback, session: { "activate_google_user" => true }
          expect(user.reload).to be_activated
        end
      end
    end
  end
end
