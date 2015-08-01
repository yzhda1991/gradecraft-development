#spec/controllers/assignment_type_weights_controller_spec.rb
require 'spec_helper'

describe AssignmentTypeWeightsController do

	context "as professor" do 
		
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @challenge = create(:challenge, course: @course)
      @course.challenges << @challenge
      @challenges = @course.challenges
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET mass_edit" do  
      it "assigns params" do
        get :mass_edit, :student_id => @student.id
        assigns(:title).should eq("Editing #{@student.name}'s multipliers")
        response.should render_template(:mass_edit)
      end
    end

		describe "POST mass_update" do  
      pending
    end

	end

	context "as student" do 
    
    before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course
      login_user(@student)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET mass_edit" do  
      it "assigns params" do
        get :mass_edit, :student_id => @student.id
        assigns(:title).should eq("Editing My multiplier Choices")
        response.should render_template(:mass_edit)
      end
    end

		describe "POST mass_update" do  
      pending
    end
    
	end

end