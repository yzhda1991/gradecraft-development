#spec/controllers/tasks_controller_spec.rb
require 'spec_helper'

describe TasksController do

  #not yet built

	context "as a professor" do 
    
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment, course: @course, assignment_type: @assignment_type)
      @task = create(:task, assignment: @assignment)
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
      it "redirects the tasks index to the assignment page" do
        get :index, :assignment_id => @assignment.id
        response.should redirect_to(assignment_path(@assignment))
      end
    end
    
    describe "GET show" do  
      pending
    end
    
		describe "GET new" do  
      pending
    end
    
		describe "GET edit" do
      pending
      it "display the edit form" do
        get :edit, {:id => @task.id, :assignment_id => @assignment.id}
        assigns(:title).should eq("Editing #{@assignment.name} Task")
        assigns(:task).should eq(@task)
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

    describe "protected routes with ids in the url" do 
      [
        :show,
        :update,
        :destroy,
        :edit
      ].each do |route|
        it "#{route} redirects to root" do
          pending
          (get route, {:id => "10"}).should redirect_to(:root)
        end
      end
    end

	end
end