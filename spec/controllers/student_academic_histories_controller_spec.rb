#spec/controllers/student_academic_histories_controller_spec.rb
require 'spec_helper'

describe StudentAcademicHistoriesController do

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

		describe "GET show" do  
      pending
    end

		describe "GET new" do  
      pending
    end

		describe "GET create" do  
      pending
    end

		describe "GET edit" do  
      pending
    end

		describe "GET update" do  
      pending
    end

		describe "GET destroy" do  
      pending
    end
    
	end

	context "as a student" do 
		describe "protected routes" do
      [
        :index,
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :show,
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          pending
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end