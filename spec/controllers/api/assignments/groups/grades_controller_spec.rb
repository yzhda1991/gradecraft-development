describe API::Assignments::Groups::GradesController do
  let(:course) { build :course }
  let(:assignment) { create :assignment, course: course }

  before(:each) { login_user user }

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "#GET index" do
      context "when the assignment is individually graded" do
        it "returns a 404 bad request" do
          get :index, params: { assignment_id: assignment.id }, format: :json

          expect(response).to have_http_status :bad_request
        end
      end

      context "when the assignment is group graded" do
        let(:assignment) { create :group_assignment, course: course }
        let!(:assignment_groups) { create_list :assignment_group, 2, assignment: assignment }

        it "returns grades by group" do
          get :index, params: { assignment_id: assignment.id }, format: :json

          expect(assigns(:assignment)).to eq assignment
          expect(assigns(:grades_by_group).length).to eq 2
          expect(response).to render_template :index
        end
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "returns a redirect status" do
        [
          -> { get :index, params: { assignment_id: assignment.id } }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
