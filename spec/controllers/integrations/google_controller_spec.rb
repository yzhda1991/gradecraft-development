describe Integrations::GoogleController, type: [:disable_external_api, :controller] do
  let(:auth_hash) do
    OmniAuth::AuthHash.new("info" => {
      "first_name" => "Pablo",
      "last_name" => "Picasso",
      "email" => "pablo.picasso@gmail.com"
    })
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

  describe "#create_user" do
    let(:user_attrs) do
      {
        "email" => "john.doe@email.com",
        "first_name" => "John",
        "last_name" => "Doe"
      }
    end

    before(:each) { session[:google_omniauth_user] = user_attrs }

    it "creates a new user from the session params" do
      expect{ post :create_user }.to change(User, :count).by(1)
      expect(User.last).to have_attributes user_attrs.merge \
        "username" => "john.doe@email.com",
        "activation_state" => "active"
    end

    it "directs the user to the course creation page on success" do
      post :create_user
      expect(response).to redirect_to new_external_courses_path(user_id: User.last.id)
    end
  end
end
