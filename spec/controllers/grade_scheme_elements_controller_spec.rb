require 'rails_spec_helper'

describe GradeSchemeElementsController do
  before(:all) { @course = create(:course) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end

    before(:each) do
      @grade_scheme_element = create(:grade_scheme_element, course: @course)
      login_user(@professor)
    end

    describe "GET index" do
      it "assigns all grade scheme elements" do
        get :index
        expect(assigns(:grade_scheme_elements)).to eq([@grade_scheme_element])
      end
    end

    describe "GET mass_edit" do
      it "shows the mass edit form" do
        get :mass_edit
        expect(assigns(:grade_scheme_elements)).to eq(@course.grade_scheme_elements)
      end
    end

    describe "GET student predictor data" do
      it "returns grade scheme elements with total points as json" do
        @grade_scheme_element.update(low_range: 1000)
        get :predictor_data, format: :json
        expect(assigns(:grade_scheme_elements)).to eq([@grade_scheme_element])
        expect(assigns(:total_points)).to eq(1100)
        expect(response).to render_template(:predictor_data)
      end
    end
  end

  context "as student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before(:each) do
      @grade_scheme_element = create(:grade_scheme_element, low_range: 1000, course: @course)
      login_user(@student)
    end

    describe "GET student predictor data" do
      it "returns grade scheme elements with total points as json" do
        get :predictor_data, format: :json
        expect(assigns(:grade_scheme_elements)).to eq([@grade_scheme_element])
        expect(assigns(:total_points)).to eq(1100)
        expect(response).to render_template(:predictor_data)
      end
    end

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
