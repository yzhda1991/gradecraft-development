#spec/controllers/rubrics_controller_spec.rb
require 'spec_helper'

describe RubricsController do

	context "as a professor" do 
    
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment = create(:assignment)
      @course.assignments << @assignment
      @rubric = create(:rubric, assignment: @assignment)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "GET design" do 
      it "shows the design form" do
        pending
        get :design,{ assignment: @assignment, rubric: @rubric}
        assigns(:title).should eq("Create a New assignment Type")
        assigns(:assignment_type).should be_a_new(AssignmentType)
        response.should render_template(:design)
      end
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
        :update,
        :existing_metrics,
        :course_badges
      ].each do |route|
          it "#{route} redirects to root" do
            (get route, {:assignment_id => 1, :id => "1"}).should redirect_to(:root)
          end
        end
    end

	end
end