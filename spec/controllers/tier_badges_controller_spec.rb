require 'rails_spec_helper'

describe TierBadgesController do
  before(:all) { @course = create(:course) }
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
      it "creates a new tier badge" do 
        params = attributes_for(:tier_badge)
        expect{ post :create, :tier_badge => params }.to change(TierBadge,:count).by(1)  
      end
    end

    describe "GET destroy" do 
      it "destroys a tier badge" do 
        @tier_badge = create(:tier_badge)
        expect{ get :destroy, { :id => @tier_badge } }.to change(TierBadge,:count).by(-1)
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
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:id => "10"}).to redirect_to(:root)
        end
      end
    end
  end
end
