describe HomeController, focus: true do
  include UniMock::StubRails

  describe "#index" do
    let(:user) { build_stubbed :user }

    it "redirects to dashboard if the user is logged in" do
      login_user user
      get :index
      expect(response).to redirect_to dashboard_path
    end
  end

  describe "#login" do

  end
end
