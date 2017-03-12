describe API::GradeSchemeElementsController do
  let(:course) { create(:course) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let!(:grade_scheme_element_high) { create(:grade_scheme_element, course: course) }
  
  before(:each) { login_user(student) }

  describe "GET index" do
    context "with Grade Scheme elements" do
      it "returns grade scheme elements with total points as json" do
        get :index, format: :json
        expect(assigns(:grade_scheme_elements)).to eq([grade_scheme_element_high])
        expect(assigns(:total_points)).to eq(grade_scheme_element_high.lowest_points)
        expect(response).to render_template(:index)
      end
    end

    context "with no Grade Scheme elements" do
      it "returns the total points in the course if no grade scheme elements are present" do
        GradeSchemeElement.destroy_all
        assignment = create(:assignment, course: course, full_points: 1000)
        get :index, format: :json
        expect(assigns(:total_points)).to eq(1000)
      end
    end

    context "with no Grade Scheme elements and no assignments" do
      it "returns the total points in the course if no grade scheme elements are present" do
        get :index, format: :json
        expect(assigns(:total_points)).to eq(0)
      end
    end
  end
end
