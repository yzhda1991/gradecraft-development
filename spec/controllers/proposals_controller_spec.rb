#spec/controllers/proposals_controller_spec.rb
require 'spec_helper'

describe ProposalsController do

	context "as a professor" do 
    
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @student = create(:user)
      @student.courses << @course
      
      @assignment = create(:assignment)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "POST create" do

    end

		describe "POST update" do  
      pending
    end

    describe "GET destroy" do
      pending
      it "destroys the proposal" do
        expect{ get :destroy, :id => @proposal }.to change(Proposal,:count).by(-1)
      end
    end

	end

	context "as a student" do
    
    before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course
      
      login_user(@student)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET create" do  
      pending
    end

		describe "POST update" do  
      pending
    end

		describe "GET destroy" do  
      pending
    end

	end

end