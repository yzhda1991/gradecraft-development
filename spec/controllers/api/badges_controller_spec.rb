require 'rails_spec_helper'

describe API::BadgesController do
  before(:all) do
    @world = World.create.with(:course, :student, :badge)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @world.course, role: "professor"
    end

    before(:each) { login_user(@professor) }

    describe "GET index" do
      it "returns badges for the current course" do
        get :index, format: :json
        expect(assigns(:badges)).to eq([@world.badge])
        expect(response).to render_template(:index)
      end
    end
  end
end
