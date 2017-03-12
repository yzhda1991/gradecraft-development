describe ErrorsController do
  let(:params) { {
      status_code: 418,
      error_type: "error"
    }
  }

  describe "show" do
    it "renders with the template with the correct layout" do
      get :show, params: params
      expect(response).to render_template layout: "error"
    end

    it "returns the specified status code if provided" do
      get :show, params: params
      expect(response.status).to eq params[:status_code]
    end

    it "returns a 500 if no status code is provided" do
      params.delete :status_code
      get :show, params: params
      expect(response.status).to eq 500
    end
  end
end
