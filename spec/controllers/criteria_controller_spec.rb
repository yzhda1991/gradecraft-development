describe CriteriaController do
  let(:course) { build :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }

  context "as a professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "creates a new criterion" do
        post :create, params: { criterion: { max_points: 100, name: "Test", order: 1, rubric_id: rubric.id }}
        criterion = Criterion.unscoped.last
        expect(criterion.name).to eq "Test"
      end
    end

    describe "GET destroy" do
      it "destroys a criterion" do
        criterion_2 = create(:criterion)
        expect{ get :destroy, params: { id: criterion_2 }}.to \
          change(Criterion,:count).by(-1)
      end
    end

    describe "POST update" do
      it "updates a criterion" do
        params = { name: "new name" }
        post :update, params: { id: criterion.id, criterion: params }
        expect(criterion.reload.name).to eq("new name")
      end
    end
  end

  context "as a student" do
    before(:each) { login_user(student) }

    describe "protected routes" do
      [
        :create,
        :update_order
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id parameter" do
      [
        :destroy,
        :update
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: 1 }).to redirect_to(:root)
        end
      end
    end
  end
end
