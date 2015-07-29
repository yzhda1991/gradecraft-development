# spec/controllers/user_sessions_controller_spec.rb
require 'spec_helper'

describe UserSessionsController do

	context "as a professor" do 
    
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

		describe "GET new" do  
      pending
    end
    
		describe "GET create" do  
      pending
    end
    
		describe "GET lti_create" do  
      pending
    end
    
		describe "GET kerberos_create" do  
      pending
    end
    
		describe "GET destroy" do  
      pending
    end
    
	end

	context "as a student" do
		describe "GET new" do  
      pending
    end
    
		describe "GET create" do  
      pending
    end
    
		describe "GET lti_create" do  
      pending
    end
    
		describe "GET kerberos_create" do  
      pending
    end
    
		describe "GET destroy" do  
      pending
    end
    
	end
end