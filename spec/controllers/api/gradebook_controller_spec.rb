describe API::GradebookController do
  let(:course) { build :course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { create :user, role: :professor, courses: [course] }

    describe "#assignments" do
      let!(:assignments) { create_list :assignment, 2, course: course }
      let!(:group_assignments) { create_list :assignment, 2, course: course }

      it "returns the id and name for all assignments in the course" do
        get :assignments, format: :json

        expect(assigns(:assignments).length).to eq 4
        expect(assigns(:assignments)).to \
          match_array [assignments, group_assignments].flatten.map { |a| { id: a.id, name: a.name } }
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, role: :student, courses: [course] }

    it "redirects protected routes" do
      [
        -> { get :assignments },
        -> { get :student_ids },
        -> { get :students }
      ].each do |protected_route|
        expect(protected_route.call).to have_http_status 302
      end
    end
  end
end
