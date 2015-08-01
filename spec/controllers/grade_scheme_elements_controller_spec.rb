#spec/controllers/grade_scheme_elements_controller_spec.rb
require 'spec_helper'

describe GradeSchemeElementsController do

	context "as professor" do 
		
    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @grade_scheme_element = create(:grade_scheme_element)
      @course.grade_scheme_elements << @grade_scheme_element
      @grade_scheme_elements = @course.grade_scheme_elements
      login_user(@professor)

      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "GET index" do
      it "assigns all grade scheme elements as @grade_scheme_elements" do
        allow(EventLogger).to receive(:perform_async).and_return(true)
        get :index
        assigns(:grade_scheme_elements).should eq([@grade_scheme_element])
      end
    end

    describe "GET mass_edit" do
      it "shows the mass edit form" do
        get :mass_edit
        assigns(:grade_scheme_elements).should eq(@grade_scheme_elements)
      end
    end

    describe "GET mass update" do
      it "updates the grade scheme elements" do
        pending
        post :mass_update, {}
        assigns(:event).should be_a_new(Event)
      end
    end

	end

	context "as student" do 

		describe "protected routes" do
      [
        :index,
        :mass_edit,
        :mass_update

      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end
	end
end