require 'rails_spec_helper'

describe MetricsController do
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
      it "creates a new metric" do 
        params = attributes_for(:metric)
        expect{ post :create, :metric => params }.to change(Metric,:count).by(1)  
      end
    end

    describe "GET destroy" do 
      it "destroys a metric" do 
        @metric = create(:metric)
        expect{ get :destroy, { :id => @metric } }.to change(Metric,:count).by(-1)
      end
    end

    describe "POST update" do 
      it "updates a metric" do 
        @metric = create(:metric)
        params = { name: "new name" }
        post :update, id: @metric.id, :metric=> params
        expect(@metric.reload.name).to eq("new name")
      end
    end

    describe "POST update_order" do 
      it "changes the order of the metrics for the rubric" do 
        @rubric = create(:rubric)
        @metric = create(:metric, order: 0, rubric: @rubric)
        @metric_2 = create(:metric, order: 1, rubric: @rubric)
        params = {"metric_order"=>{"#{@metric.id}"=>{"order"=>1}, "#{@metric_2.id}"=>{"order"=>0} } }
        post :update_order, params
        expect(@metric.reload.order).to eq(1)
        expect(@metric_2.reload.order).to eq(0)
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
        :create,
        :update_order
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id parameter" do
      [
        :destroy,
        :update
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, id: 1).to redirect_to(:root)
        end
      end
    end
  end
end
