describe API::AssignmentTypesController do
  let(:course) { build :course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment_type) { create(:assignment_type, course: course) }
  let(:assignment) { create(:assignment, assignment_type: assignment_type, course: course) }

  context "as a professor" do
    before do
      login_user(professor)
    end

    describe "GET index" do
      it "returns assignment types without weights update" do
        get :index, format: :json
        expect(assigns(:assignment_types)).to eq([assignment_type])
        expect(assigns(:update_weights)).to be_falsey
        expect(assigns(:student)).to be_nil
        expect(response).to render_template(:index)
      end
    end

    describe "GET sort" do
      it "sorts the assignment types by params" do
        second_assignment_type = create(:assignment_type, course: course)
        course.assignment_types << second_assignment_type
        params = [second_assignment_type.id, assignment_type.id]
        post :sort, params: { "assignment-type" => params }

        assignment_type.reload
        second_assignment_type.reload
        expect(assignment_type.position).to eq(2)
        expect(second_assignment_type.position).to eq(1)
      end
    end
  end

  context "as a student" do
    before do
      login_user(student)
    end

    describe "GET index" do
      it "returns badges for the current course" do
        get :index, format: :json
        expect(assigns(:student)).to eq(student)
        expect(assigns(:assignment_types)).to eq([assignment_type])
        expect(assigns(:update_weights)).to be_truthy
        expect(response).to render_template(:index)
      end
    end

    it "redirects protected routes to root" do
      [
        -> { post :sort, params: { "assignment-type" => [assignment_type] }, format: :json}
      ].each do |protected_route|
        expect(protected_route.call).to redirect_to(:root)
      end
    end
  end
end
