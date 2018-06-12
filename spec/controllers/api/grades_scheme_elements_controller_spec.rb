describe API::GradeSchemeElementsController do
  let(:course) { build :course }

  before(:each) { login_user user }

  context "as a student" do
    let(:user) { create :user, courses: [course], role: :student }

    describe "GET index" do
      context "when grade scheme elements exist" do
        let!(:grade_scheme_element) { create :grade_scheme_element, course: course }

        it "returns grade scheme elements with total points" do
          get :index, format: :json
          expect(assigns(:grade_scheme_elements)).to eq [grade_scheme_element]
          expect(assigns(:total_points)).to eq grade_scheme_element.lowest_points
          expect(response).to render_template :index
        end
      end

      context "when no grade scheme elements exist" do
        it "returns the total points in the course if no grade scheme elements are present" do
          create :assignment, course: course, full_points: 1000
          get :index, format: :json
          expect(assigns(:total_points)).to eq 1000
        end

        it "returns the total points in the course if no grade scheme elements are present" do
          get :index, format: :json
          expect(assigns(:total_points)).to eq 0
        end
      end
    end

    describe "protected routes" do
      it "redirect to root" do
        [
          -> { delete :destroy_all },
          -> { put :update, params: { id: 1 } }
        ].each do |protected_route|
          expect(protected_route.call).to redirect_to :root
        end
      end
    end
  end

  context "as a professor" do
    let(:user) { create :user, courses: [course], role: :professor }

    describe "GET index" do
      let!(:grade_scheme_element) { create :grade_scheme_element, course: course }

      it "returns the grade scheme elements with total points" do
        get :index, format: :json
        expect(assigns(:grade_scheme_elements)).to eq [grade_scheme_element]
        expect(assigns(:total_points)).to eq grade_scheme_element.lowest_points
        expect(response).to render_template :index
      end
    end

    describe "PUT update" do
      let(:grade_scheme_element) { create :grade_scheme_element, course: course }
      let(:params) do
        { "grade_scheme_elements_attributes" => [{
          id: grade_scheme_element.id, letter: "C", level: "Sea Slug", lowest_points: 0,
          course_id: course.id }, { id: nil,
          letter: "B", level: "Snail", lowest_points: 100001,
          course_id: course.id }], "deleted_ids"=>nil }
      end

      it "updates the grade scheme elements" do
        put :update, params: params, format: :json
        expect(course.reload.grade_scheme_elements.count).to eq 2
        expect(grade_scheme_element.reload.level).to eq "Sea Slug"
      end

      it "recalculates scores for all students in the course" do
        expect{ put :update, params: params, format: :json }.to \
          change{ queue(ScoreRecalculatorJob).size }.by course.students.count
      end

      it "deletes grades scheme elements" do
        params = { "deleted_ids"=>[grade_scheme_element.id] }
        expect{ put :update, params: params, format: :json }.to \
          change{ GradeSchemeElement.count }.by -1
      end
    end

    describe "DELETE destroy_all" do
      before(:each) { allow(controller).to receive(:current_course).and_return course }

      context "with no grade scheme elements" do
        it "returns a status OK" do
          delete :destroy_all
          expect(response.status).to eq 200
        end
      end

      context "with grade scheme elements" do
        let!(:grade_scheme_element) { create :grade_scheme_element, course: course }

        it "returns a status OK if the elements were deleted" do
          delete :destroy_all
          expect(response.status).to eq 200
        end

        it "returns a 500 status if not all elements were deleted" do
          allow(course.grade_scheme_elements).to receive(:any?).and_return 1
          delete :destroy_all
          expect(response).to have_http_status :internal_server_error
        end
      end
    end
  end
end
