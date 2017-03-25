describe API::GradeSchemeElementsController do
  let(:course) { build :course }

  context "as a student" do
    let(:student) { build_stubbed :user, courses: [course], role: :student }
    before(:each) { login_user student }

    describe "GET index" do
      context "with Grade Scheme elements" do
        let!(:grade_scheme_element_high) { create :grade_scheme_element, course: course }

        it "returns grade scheme elements with total points as json" do
          get :index, format: :json
          expect(assigns(:grade_scheme_elements)).to eq([grade_scheme_element_high])
          expect(assigns(:total_points)).to eq(grade_scheme_element_high.lowest_points)
          expect(response).to render_template(:index)
        end
      end

      context "with no Grade Scheme elements" do
        it "returns the total points in the course if no grade scheme elements are present" do
          create :assignment, course: course, full_points: 1000
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

    describe "DELETE destroy" do
      it "redirects to root" do
        expect(delete :destroy).to redirect_to root_path
      end
    end
  end

  context "as a professor" do
    let(:professor) { build_stubbed :user, courses: [course], role: :professor }
    before(:each) { login_user professor }

    describe "DELETE destroy" do
      before(:each) { allow(controller).to receive(:current_course).and_return course }

      context "with no grade scheme elements" do
        it "returns a status OK" do
          delete :destroy
          expect(response.status).to eq 200
        end
      end

      context "with grade scheme elements" do
        let!(:grade_scheme_element) { create :grade_scheme_element, course: course }

        it "returns a status OK if the elements were deleted" do
          delete :destroy
          expect(response.status).to eq 200
        end

        it "returns a status Internal Server Error if the elements were not deleted" do
          allow(course.grade_scheme_elements).to receive(:any?).and_return 1
          delete :destroy
          expect(response.status).to eq 500
        end
      end
    end
  end
end
