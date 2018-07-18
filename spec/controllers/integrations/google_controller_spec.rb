describe Integrations::GoogleController, type: [:disable_external_api, :controller] do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      "first_name" => "Pablo",
      "last_name" => "Picasso",
      "email" => "pablo.picasso@gmail.com"
    )
  end

  describe "#auth_callback" do
    before(:each) do
      allow(controller).to receive_messages \
        require_authorization_with: true,
        auth_hash: auth_hash
      allow(UserAuthorization).to receive(:create_by_auth_hash).and_return true
    end

    xit "requires authorization"

    context "when the user is logged in" do
      let(:user) { build_stubbed :user }

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

      it "redirects them to a confirmation page if they do not have an existing account" do
        get :auth_callback
        expect(response).to redirect_to action: :new_user
      end

      it "sets the omniauth info in the session if they do not have an existing account" do
        get :auth_callback
        expect(session[:google_omniauth_user]).to include \
          email: "pablo.picasso@gmail.com",
          first_name: "Pablo",
          last_name: "Picasso"
      end
    end
  end
end
