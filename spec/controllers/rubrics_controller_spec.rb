#spec/controllers/rubrics_controller_spec.rb
require 'spec_helper'

describe RubricsController do

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

		describe "GET design" do  
      pending
    end

		describe "GET create" do  
      pending
    end

		describe "GET destroy" do  
      pending
    end

		describe "GET update" do  
      pending
    end

		describe "GET existing_metrics" do  
      pending
    end

		describe "GET course_badges" do  
      pending
    end
	end

	context "as a student" do 
		describe "protected routes" do
      [
        :design,
        :create, 
        :destroy,
        :show,
        :update,
        :existing_metrics,
        :course_badges
      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end

	end
end