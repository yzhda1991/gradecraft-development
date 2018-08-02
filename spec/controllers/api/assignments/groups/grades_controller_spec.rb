describe API::Assignments::Groups::GradesController do
  let(:course) { build :course }
  let(:individual_assignment) { create :assignment, course: course }
  let(:group_assignment) { create :group_assignment, course: course }

  before(:each) { login_user user }

  context "as a professor" do
    let(:user) { create :user, courses: [course], role: :professor }

    describe "#GET index" do
      context "when the assignment is individually graded" do
        it "returns a 404" do
          get :index, params: { assignment_id: individual_assignment.id }, format: :json
          expect(response).to have_http_status :bad_request
        end
      end

      context "when the assignment is group-graded" do
        let!(:assignment_groups) { create_list :assignment_group, 2, assignment: group_assignment }

        it "assigns the groups and the associated grades" do
          get :index, params: { assignment_id: group_assignment }, format: :json
          expect(assigns(:groups)).to match_array assignment_groups.map(&:group)
          expect(assigns(:group_grades)).to_not be_nil
        end
      end
    end

    describe "#GET mass_edit" do
      context "when the assignment is individually graded" do
        it "returns a 404 bad request" do
          get :mass_edit, params: { assignment_id: individual_assignment.id }, format: :json
          expect(response).to have_http_status :bad_request
        end
      end

      context "when the assignment is group graded" do
        let!(:assignment_groups) { create_list :assignment_group, 2, assignment: group_assignment }

        it "returns grades by group" do
          get :mass_edit, params: { assignment_id: group_assignment.id }, format: :json
          expect(assigns(:assignment)).to eq group_assignment
          expect(assigns(:grades_by_group).length).to eq 2
        end
      end
    end
  end

  context "as a student" do
    let(:user) { create :user, courses: [course], role: :student }

    describe "protected routes" do
      it "returns a redirect status" do
        [
          -> { get :index, params: { assignment_id: individual_assignment.id } },
          -> { get :mass_edit, params: { assignment_id: individual_assignment.id } }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
