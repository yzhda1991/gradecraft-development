require "rails_spec_helper"

describe ErrorsController do
  let(:user) { build_stubbed(:user) }
  let(:params) { ActionController::Parameters.new(
      status_code: 418,
      message: "whoa what just happened?",
      header: "Something went terribly wrong",
      redirect_path: dashboard_path
    )
  }

  before(:each) { login_user(user) }

  describe "show" do
    it "creates a presenter with the proper attributes" do
      sanitized_params = params.permit(:message, :header, :redirect_path)
      expect(Errors::ShowPresenter).to receive(:new).with sanitized_params
      get :show, params: params
    end

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
