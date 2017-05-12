describe API::CriteriaController do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let!(:rubric) { create(:rubric, assignment: assignment) }
  let!(:criterion) { create(:criterion, rubric: rubric) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns criteria for the current assignment" do
        get :index, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:criteria)[0].id).to eq(rubric.criteria[0].id)
        expect(response).to render_template(:index)
      end
    end

    describe "PUT set_expectations" do
      let(:level) { criterion.levels.last }

      it "sets epxectations for the level in params" do
        put :set_expectations, criterion_id: criterion.id, level_id: level.id, format: :json
        expect(level.reload.meets_expectations).to be_truthy
        expect(criterion.reload.meets_expectations_level_id).to eq(level.id)
        expect(criterion.reload.meets_expectations_points).to eq(level.points)
      end

      it "removes expectations for all other levels" do
        criterion.levels.first.update_attributes(meets_expectations: true)
        put :set_expectations, criterion_id: criterion.id, level_id: level.id, format: :json
        expect(criterion.levels.first.reload.meets_expectations).to be_falsey
      end
    end

    describe "PUT remove_expectations" do
      it "removes expectations on criteria and all levels" do
        criterion.levels.first.update_attributes(meets_expectations: true)
        put :remove_expectations, criterion_id: criterion.id, format: :json
        expect(criterion.levels.pluck(:meets_expectations).uniq).to eq([false])
      end
    end
  end
end
