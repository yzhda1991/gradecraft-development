require "rails_spec_helper"

describe LTIController do
  let(:user) { build_stubbed(:user) }
  before(:each) { login_user(user) }

  describe "#error", focus: true do
    context "if params are present" do
      let(:params) { {
        message: "whoa there, what just happened?",
        redirect_path: dashboard_path,
        header: "A serious thing just happened",
        status_code: "418" }
      }

      it "assigns the attributes to the error" do
        get :error, params: params
        expect(assigns(:error)).to_not be_nil
        expect(assigns(:error)).to have_attributes params
        expect(response.status).to eq 418
      end
    end

    context "if params are not present" do
      it "provides default attributes for the error" do
        get :error
        expect(assigns(:error)).to_not be_nil
        expect(assigns(:error).message).to_not be_nil
        expect(assigns(:error).header).to_not be_nil
        expect(assigns(:error).status_code).to_not be_nil
        expect(assigns(:error).redirect_path).to_not be_nil
      end
    end
  end
end
