describe Integrations::GoogleController, type: [:disable_external_api, :controller] do
  let(:user) { build_stubbed :user }
  let(:auth_hash) do
    OmniAuth::AuthHash.new("info" => {
      "first_name" => "Pablo",
      "last_name" => "Picasso",
      "email" => "pablo.picasso@gmail.com"
    })
  end

  describe "#new_user" do
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

  describe "#auth_callback" do
    before(:each) do
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
      it "automatically logs the user in if they have an existing account" do
        user = create :user, email: "pablo.picasso@gmail.com"
        get :auth_callback
        expect(controller.current_user).to eq user
      end

      it "creates a new account if there is not one that matches the email" do
        expect{ get :auth_callback }.to change(User, :count).by 1
        expect(User.last).to have_attributes \
          "first_name" => "Pablo",
          "last_name" => "Picasso",
          "email" => "pablo.picasso@gmail.com",
          "username" => "pablo.picasso@gmail.com",
          "activation_state" => "active"
      end

      it "finds or creates the user and logs them in" do
        get :auth_callback
        expect(controller.current_user).to eq User.last
      end

      it "redirects to the new user page if their account was just created" do
        get :auth_callback
        expect(response).to redirect_to action: :new_user
      end
    end
  end
end
