require 'spec_helper'

describe UsersController do

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

		describe "GET index" do  
      pending
    end
    
		describe "GET new" do  
      pending
    end
    
		describe "GET edit" do  
      pending
    end
    
		describe "GET create" do  
      pending
    end
    
		describe "GET update" do  
      pending
    end
    
		describe "GET destroy" do  
      pending
    end
    
		describe "GET edit_profile" do  
      pending
    end
    
		describe "GET update_profile" do  
      pending
    end
    
		describe "GET import" do  
      pending
    end
    
		describe "GET upload" do  
      pending
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

		describe "GET edit_profile" do  
      pending
    end
    
		describe "GET update_profile" do  
      pending
    end
    

		describe "protected routes" do
      [
        :index,
        :new,
        :create,
        :import,
        :upload
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end
