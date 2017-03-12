describe API::CriteriaController do
  let(:course) { create :course }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let!(:rubric) { create(:rubric, assignment: assignment) }
  let!(:criterion) { create(:criterion, rubric: rubric) }
  let(:criterion_grade) { create(:criterion_grade, criterion: criterion) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET criteria" do
      it "returns criteria for the current assignment" do
        get :index, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:criteria)[0].id).to eq(rubric.criteria[0].id)
        expect(response).to render_template(:index)
      end
    end
  end
end
