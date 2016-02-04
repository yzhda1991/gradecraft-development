require 'rails_spec_helper'

describe API::CriteriaController do
  before(:all) do
    @world = World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @world.course, role: "professor"
    end

    before(:each) { login_user(@professor) }

    describe "GET criteria" do
      it "returns criteria for the current assignment" do
        get :index, id: @world.assignment.id, format: :json
        expect(assigns(:criteria)[0].id).to eq(@world.criteria[0].id)
        expect(response).to render_template(:index)
      end
    end
  end
end
