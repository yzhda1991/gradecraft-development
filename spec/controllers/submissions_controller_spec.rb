#spec/controllers/submissions_controller_spec.rb
require 'spec_helper'

describe SubmissionsController do

	context "as a professor" do 

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment, course: @course, assignment_type: @assignment_type)
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams

      @submission = create(:submission, assignment_id: @assignment.id, assignment_type: @assignment_type, student_id: @student.id, course_id: @course.id)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end
    
		describe "GET index" do  
      it "redirects the submissions index to the assignment page" do
        get :index, :assignment_id => @assignment.id
        response.should redirect_to(assignment_path(@assignment))
      end
    end

    describe "GET show" do 
      it "returns the submission show page" do
        get :show, {:id => @submission.id, :assignment_id => @assignment.id}
        assigns(:title).should eq("#{@student.first_name}'s #{@assignment.name} Submission (#{@assignment.point_total} points)")
        assigns(:submission).should eq(@submission)
        response.should render_template(:show)
      end
    end
    
    describe "GET new" do
      it "assigns title and assignment relation" do
        get :new, assignment_id: @assignment.id
        assigns(:title).should eq("Submit #{@assignment.name} (#{@assignment.point_total} points)")
        assigns(:submission).should be_a_new(Submission)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "display the edit form" do
        get :edit, {:id => @submission.id, :assignment_id => @assignment.id}
        assigns(:title).should eq("Editing #{@submission.student.name}'s Submission")
        assigns(:submission).should eq(@submission)
        response.should render_template(:edit)
      end
    end
    
		describe "GET create" do  
      pending
    end
    
		describe "GET update" do  
      pending
    end
    
    describe "GET destroy" do
      it "destroys the submission" do
        expect{ get :destroy, {:id => @submission, :assignment_id => @assignment.id } }.to change(Submission,:count).by(-1)
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

		describe "GET new" do  
      pending
    end
     
		describe "GET edit" do  
      pending
    end
     
		describe "GET create" do  
      pending
    end
    
		describe "GET show" do  
      pending
    end
    
		describe "GET update" do  
      pending
    end
    

		describe "protected routes" do
      [
        :index,
        :destroy
      ].each do |route|
          it "#{route} redirects to root" do
          	pending
            (get route).should redirect_to(:root)
          end
        end
    end

	end
end