describe GradeSchemeElementsController do
  let(:course) { build(:course) }
  let!(:grade_scheme_element) do
    create :grade_scheme_element, letter: "A", course: course,
      lowest_points: 3000
  end

  before(:each) do
    login_user user
  end

  context "as professor" do
    let(:user) { create :user, courses: [course], role: :professor }

    describe "GET index" do
      it "assigns all grade scheme elements" do
        get :index
        expect(assigns(:grade_scheme_elements)).to eq [grade_scheme_element]
      end
    end

    describe "GET edit" do
      it "renders the edit grade scheme form" do
        get :edit, params: { id: grade_scheme_element.id }
        expect(assigns(:grade_scheme_element)).to eq grade_scheme_element
        expect(response).to render_template :edit
      end
    end

    describe "PUT update" do
      it "updates the grade scheme element" do
        grade_scheme_element_params = { letter: "B" }
        put :update, params: { id: grade_scheme_element.id, grade_scheme_element: grade_scheme_element_params }
        expect(grade_scheme_element.reload.letter).to eq "B"
      end
    end

    describe "GET export_structure" do
      it "retrieves the export_structure download" do
        get :export_structure, params: { id: course.id }, format: :csv
        expect(response.body).to include "Level ID,Letter Grade,Level Name,Lowest Points"
      end
    end
  end

  context "as student" do
    let(:user) { create :user, courses: [course], role: :user }

    it "redirects protected routes to root" do
      [
        -> { get :mass_edit },
        -> { get :edit, params: { id: 1 } },
        -> { put :update, params: { id: 1 } },
        -> { get :export_structure }
      ].each do |protected_route|
        expect(protected_route.call).to redirect_to :root
      end
    end
  end
end
