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
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET index" do
      it "assigns all grade scheme elements as @grade_scheme_elements" do
        allow(Resque).to receive(:enqueue).and_return(true)
        get :index
        expect(assigns(:grade_scheme_elements)).to eq([@grade_scheme_element])
      end
    end

    describe "GET mass_edit" do
      it "shows the mass edit form" do
        get :mass_edit
        expect(assigns(:grade_scheme_elements)).to eq(@grade_scheme_elements)
      end
    end

    describe "GET mass update" do
      it "updates the grade scheme elements" do
        skip "implement"
        post :mass_update, {}
        expect(assigns(:event)).to be_a_new(Event)
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
            expect(get route).to redirect_to(:root)
          end
        end
    end
  end
end
