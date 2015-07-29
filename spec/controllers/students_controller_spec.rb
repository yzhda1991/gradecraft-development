#spec/controllers/students_controller_spec.rb
require 'spec_helper'

describe StudentsController do

	context "as a professor" do 
    
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
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
      it "returns the students for the current course" do
        get :index
        assigns(:title).should eq("Player Roster")
        assigns(:students).should eq([@student])
        response.should render_template(:index)
      end
    end

    describe "GET show" do 
      it "shows the student page" do
        get :show, {:id => @student.id}
        assigns(:student).should eq(@student)
        response.should render_template(:show)
      end
    end

		describe "GET leaderboard" do  
      pending
    end

		describe "GET syllabus" do  
      pending
    end

		describe "GET timeline" do  
      pending
    end

		describe "GET autocomplete_student_name" do  
      pending
    end

		describe "GET course_progress" do  
      pending
    end

		describe "GET badges" do  
      pending
    end

		describe "GET predictor" do  
      pending
    end

		describe "GET scores_by_assignment" do  
      pending
    end

		describe "GET grade_index" do  
      pending
    end

		describe "GET recalculate" do  
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

		describe "GET syllabus" do  
      pending
    end

		describe "GET timeline" do  
      pending
    end

		describe "GET course_progress" do  
      pending
    end

		describe "GET badges" do  
      pending
    end

		describe "GET predictor" do  
      pending
    end

		describe "GET scores_by_assignment" do  
      pending
    end
    
		describe "GET course_progress" do  
      pending
    end

		describe "protected routes" do
      [
        :index,
        :leaderboard,
        :autocomplete_student_name
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :show,
        :grade_index,
        :recalculate
      ].each do |route|
        it "#{route} redirects to root" do
          pending
          (get route, {:id => "10"}).should redirect_to(:root)
        end
      end
    end

	end
end