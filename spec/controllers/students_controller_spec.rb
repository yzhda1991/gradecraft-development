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
      @assignment = create(:assignment)
      @course.assignments << @assignment
      @grade = create(:grade, assignment: @assignment, student: @student)
      @student.grades << @grade
      @grades = @student.grades
      @badge = create(:badge)
      @second_badge = create(:badge)
      @course.badges << [@badge, @second_badge]
      @earned_badge = create(:earned_badge, student_visible: true)
      @student.earned_badges << @earned_badge
      @earned_badges = @student.earned_badges

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
      it "shows the class leaderboard" do
        get :leaderboard
        assigns(:title).should eq("Leaderboard")
        response.should render_template(:leaderboard)
      end
    end

		describe "GET syllabus" do  
      it "shows the class syllabus" do
        get :syllabus, :id => 10
        response.should render_template(:syllabus)
      end
    end

		describe "GET timeline" do  
      it "shows the course timeline" do
        get :timeline, :id => 10
        response.should render_template(:timeline)
      end
    end

		describe "GET autocomplete_student_name" do  
      it "provides a list of all students and their ids" do
        get :autocomplete_student_name, :id => 10
        (expect(response.status).to eq(200))
      end
    end

		describe "GET course_progress" do  
      it "shows the course progress" do
        get :course_progress, :id => 10
        assigns(:title).should eq("Your Course Progress")
        response.should render_template(:course_progress)
      end
    end

		describe "GET badges" do
      it "shows the student facing badge page" do
        pending
        get :badges, :id => @student.id
        assigns(:title).should eq("badges")
        response.should render_template(:badges)
      end
    end

		describe "GET predictor" do  
      it "shows the grade predictor page" do
        get :predictor, :id => 10
        response.should render_template(:predictor)
      end
    end

		describe "GET scores_by_assignment" do  
      it "provides a list of all assignments and their scores" do
        get :scores_by_assignment
        (expect(response.status).to eq(200))
      end
    end

		describe "GET grade_index" do  
      it "shows the grade index page" do
        get :grade_index, :student_id => @student.id
        StudentsController.stub(:current_student).and_return(@student)
        response.should render_template(:grade_index)
      end
    end

		describe "GET recalculate" do  
      it "triggers the recalculation of a student's grade" do
        get :recalculate, { :student_id => @student.id }
        response.should redirect_to(student_path(@student))
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

		describe "GET syllabus" do  
      it "shows the class syllabus" do
        get :syllabus
        response.should render_template(:syllabus)
      end
    end

		describe "GET timeline" do  
      it "shows the course timeline" do
        get :timeline, :id => 10
        response.should redirect_to(dashboard_path)
      end
    end

		describe "GET course_progress" do  
      it "shows the course progress" do
        get :course_progress, :id => 10
        assigns(:title).should eq("Your Course Progress")
        response.should render_template(:course_progress)
      end
    end

		describe "GET badges" do  
      it "shows the student facing badge page" do
        get :badges
        assigns(:title).should eq("badges")
        response.should render_template(:badges)
      end
    end

		describe "GET predictor" do  
      it "shows the grade predictor page" do
        get :predictor, :id => 10
        response.should render_template(:predictor)
      end
    end

		describe "protected routes" do
      [
        :index,
        :leaderboard,
        :autocomplete_student_name,
        :scores_by_assignment,
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :grade_index,
        :recalculate
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:student_id => "10"}).should redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id in params" do
      [
        :show
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "10"}).should redirect_to(:root)
        end
      end
    end

	end
end