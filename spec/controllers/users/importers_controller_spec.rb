describe Users::ImportersController do
  let(:course) { build :course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:provider) { :canvas }
    let(:access_token) { "BLAH" }
    let(:user) { create :user, courses: [course], role: :professor }
    let!(:user_authorization) do
      create :user_authorization, :canvas, user: user, access_token: access_token,
        expires_at: 2.days.from_now
    end

    describe "#users_import" do
      let(:id) { 1 }
      let(:user_ids) { [12, 23] }

      before(:each) do
        allow(Services::ImportsLMSUsers).to receive(:import).and_return result
      end

      context "when successful" do
        let(:result) { double(:result, success?: true, message: "") }

        it "imports the lms users" do
          expect(Services::ImportsLMSUsers).to receive(:import).and_return result
          post :users_import, params: { id: id, importer_provider_id: provider,
            user_ids: user_ids }
        end

        it "renders the results if successful" do
          post :users_import, params: { id: id, importer_provider_id: provider,
            user_ids: user_ids }
          expect(response).to render_template :user_import_results
        end
      end

      context "when unsuccessful" do
        let(:result) { double(:result, success?: false) }

        it "redirects to the user import page" do
          post :users_import, params: { id: id, importer_provider_id: provider,
            user_ids: user_ids }
          expect(response).to redirect_to users_importer_users_path(provider, id)
        end
      end
    end

    describe "GET #download" do
      it "returns sample csv data" do
        get :download, params: { importer_provider_id: "csv", format: "csv" }

        expect(response.body).to \
          include("First Name","Last Name","Username","Email","Team Name")
      end
    end

  end
end
