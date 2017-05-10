describe InstitutionsController do
  let(:course) { build :course }

  before(:each) { login_user user }

  context "as an admin" do
    let(:user) { build_stubbed :user, courses: [course], role: :admin }

    describe "GET #new" do
      it "assigns the institution" do
        get :new
        expect(assigns(:institution)).to be_a_new(Institution)
        expect(response).to render_template(:new)
      end
    end

    describe "POST #create" do
      let(:institution) { Institution.unscoped.last }
      let(:provider) { institution.providers.unscoped.last }
      let(:institution_params) do
        {
          name: "umich",
          has_site_license: true,
          providers_attributes: { "0" => provider_attributes }
        }
      end
      let(:provider_attributes) do
        {
          name: "canvas",
          base_url: "www.canvas.edu",
          consumer_key: "abc",
          consumer_secret: "123",
          consumer_secret_confirmation: "123"
        }
      end

      it "creates the institution" do
        expect{ post :create, params: { institution: institution_params } }.to \
          change { Institution.count }.by 1
        expect(institution.name).to eq "umich"
        expect(institution.has_site_license).to eq true
      end

      it "creates the providers" do
        expect{ post :create, params: { institution: institution_params } }.to \
          change { Provider.count }.by 1
        expect(provider.name).to eq "canvas"
        expect(provider.base_url).to eq "www.canvas.edu"
        expect(provider.consumer_key).to eq "abc"
        expect(provider.consumer_secret).to eq "123"
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "GET #new" do
      it "is a protected route" do
        get :new
        expect(response).to have_http_status 302
      end
    end

    describe "POST #create" do
      it "is a protected route" do
        post :create
        expect(response).to have_http_status 302
      end
    end
  end
end
