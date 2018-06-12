describe InstitutionsController do
  let(:course) { build :course }
  let(:institution) { create :institution }

  before(:each) { login_user user }

  context "as an admin" do
    let(:user) { create :user, courses: [course], role: :admin }

    describe "GET #index" do
      before(:each) { create_list(:institution, 2) }

      it "assigns the institutions" do
        get :index
        expect(assigns(:institutions).length).to eq 2
        expect(response).to render_template :index
      end
    end

    describe "GET #new" do
      it "assigns the institution" do
        get :new
        expect(assigns(:institution)).to be_a_new Institution
        expect(response).to render_template :new
      end
    end

    describe "GET #edit" do
      it "assigns the institution" do
        get :edit, params: { id: institution.id }
        expect(assigns(:institution)).to eq institution
        expect(response).to render_template :edit
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

    describe "PUT #update" do
      let(:provider) { create :provider, institution: institution }
      let(:institution) { create :institution, :without_site_license, name: "hogwarts" }
      let(:params) do
        {
          name: "umich",
          has_site_license: true,
          providers_attributes: { "0" => provider_attributes }
        }
      end
      let(:provider_attributes) do
        {
          name: "blackboard",
          consumer_key: "abc",
          consumer_secret: "123",
          consumer_secret_confirmation: "123"
        }
      end

      it "updates the attributes" do
        put :update, params: { institution: params, id: institution.id }
        expect(institution.reload).to \
          have_attributes params.except(:providers_attributes)
        expect(institution.reload.providers.first).to \
          have_attributes provider_attributes.except(:consumer_secret_confirmation)
      end
    end
  end

  context "as a student" do
    let(:user) { build :user, courses: [course], role: :student }

    it "redirects protected routes to root" do
      [
        -> { get :index },
        -> { get :new },
        -> { get :edit, params: { id: institution.id } },
        -> { post :create },
        -> { put :update, params: { id: institution.id } }
      ].each do |protected_route|
        expect(protected_route.call).to have_http_status 302
      end
    end
  end
end
