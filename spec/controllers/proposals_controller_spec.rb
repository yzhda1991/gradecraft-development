require 'rails_spec_helper'

describe ProposalsController do
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
      @group = create(:group)
    end

    before do
      @proposal = create(:proposal)
      login_user(@professor)
    end

    describe "POST create" do 
      it "creates a new proposal" do 
        params = attributes_for(:proposal)
        expect{ post :create, :group_id => @group.id, :id => @proposal.id, :proposal => params }.to change(Proposal,:count).by(1)  
      end
    end

    describe "POST update" do 
      it "updates the requested proposal" do
        params = { title: "new name" }
        post :update, :group_id => @group.id, id: @proposal.id, :proposal => params
        expect(@proposal.reload.title).to eq("new name")
      end
    end

    describe "GET destroy" do
      it "destroys the proposal" do
        expect{ delete :destroy, :group_id => @group.id, :id => @proposal.id }.to change(Proposal,:count).by(-1)
      end
    end
  end

  context "as a student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
      @group = create(:group)
    end

    before(:each) do
      @proposal = create(:proposal)
      login_user(@student)
    end

    describe "POST create" do 
      it "creates a new proposal" do 
        params = attributes_for(:proposal)
        expect{ post :create, :group_id => @group.id, :id => @proposal.id, :proposal => params }.to change(Proposal,:count).by(1)  
      end
    end

    describe "POST update" do 
      it "updates the requested proposal" do
        params = { title: "new name" }
        post :update, :group_id => @group.id, id: @proposal.id, :proposal => params
        expect(@proposal.reload.title).to eq("new name")
      end
    end

    describe "GET destroy" do
      it "destroys the proposal" do
        expect{ delete :destroy, :group_id => @group.id, :id => @proposal.id }.to change(Proposal,:count).by(-1)
      end
    end
  end
end
