require 'rails_spec_helper'

describe TiersController do
  before(:all) do 
    @course = create(:course)
  end
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do 
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end

    before(:each) { login_user(@professor) }

    describe "POST create" do 
      it "creates a new tier" do 
        params = attributes_for(:tier)
        expect{ post :create, :tier => params }.to change(Tier,:count).by(1)  
      end
    end

    describe "GET destroy" do 
      it "destroys a tier" do 
        @tier = create(:tier)
        expect{ get :destroy, { :id => @tier } }.to change(Tier,:count).by(-1)
      end
    end

    describe "POST update" do 
      it "updates a tier" do 
        @tier = create(:tier)
        params = { name: "new name" }
        post :update, id: @tier.id, :tier=> params
        expect(@tier.reload.name).to eq("new name")
      end
    end
  end

  context "as a student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before(:each) { login_user(@student) }

    describe "protected routes" do
      [
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:id => "10"}).to redirect_to(:root)
        end
      end
    end
  end
end
