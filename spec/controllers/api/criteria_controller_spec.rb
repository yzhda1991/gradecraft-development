describe API::CriteriaController do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let!(:rubric) { create(:rubric, assignment: assignment) }
  let!(:criterion) { create(:criterion, rubric: rubric) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "creates a new criteria" do
        expect{ post :create,
                params: { criterion: {rubric_id: rubric.id, name: "New Criterion", max_points: 1000, order: 2 }},
                format: :json
              }.to change(rubric.criteria, :count).by(1)
        expect(assigns(:criterion).name).to eq("New Criterion")
      end
    end

    describe "GET index" do
      it "returns criteria for the current assignment" do
        get :index, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:criteria)[0].id).to eq(rubric.criteria[0].id)
        expect(response).to render_template(:index)
      end
    end

    describe "PUT update" do
      let(:params) do
        { id: criterion.id, criterion: { name: "A new name", max_points: 54321, description: "A new description" }}
      end

      it "updates the criterion attributes" do
        put :update, params: params, format: :json
        expect(criterion.reload.name).to eq("A new name")
        expect(criterion.max_points).to eq(54321)
        expect(criterion.description).to eq("A new description")
      end

      it "renders success message when request format is JSON" do
        put :update, params: params, format: :json
        expect(response.status).to eq(200)
        expect(assigns(:criterion)).to eq(criterion)
      end

      describe "on error" do
        it "describes failure to update" do
          allow_any_instance_of(Criterion).to receive(:update_attributes) { false }
          put :update, params: params, format: :json
          expect(JSON.parse(response.body)).to eq("errors"=>[{"detail"=>"failed to update criterion"}], "success"=>false)
          expect(response.status).to eq(500)
        end
      end
    end

    describe "PUT update_order" do
      it "changes the order of the criteria for the rubric" do
        criterion = create(:criterion, order: 0, rubric: rubric)
        criterion_2 = create(:criterion, order: 1, rubric: rubric)
        params = {"criteria_ids"=>[criterion_2.id,criterion.id] }
        put :update_order, params: params, format: :json
        expect(criterion.reload.order).to eq(1)
        expect(criterion_2.reload.order).to eq(0)
      end
    end

    describe "DELETE criterion" do
      it "removes the criterion from the rubric" do
        delete :destroy, params: { id: criterion.id}, format: :json
        expect(rubric.criteria.count).to eq(0)
        expect(JSON.parse(response.body)).to eq("message"=>"criterion successfully deleted", "success"=>true)
      end
    end

    describe "PUT set_expectations" do
      let(:level) { criterion.levels.last }

      it "sets epxectations for the level in params" do
        put :set_expectations, params: { criterion_id: criterion.id, level_id: level.id }, format: :json
        expect(level.reload.meets_expectations).to be_truthy
        expect(criterion.reload.meets_expectations_level_id).to eq(level.id)
        expect(criterion.reload.meets_expectations_points).to eq(level.points)
      end

      it "removes expectations for all other levels" do
        criterion.levels.first.update_attributes(meets_expectations: true)
        put :set_expectations, params: { criterion_id: criterion.id, level_id: level.id }, format: :json
        expect(criterion.levels.first.reload.meets_expectations).to be_falsey
      end
    end

    describe "PUT remove_expectations" do
      it "removes expectations on criteria and all levels" do
        criterion.levels.first.update_attributes(meets_expectations: true)
        put :remove_expectations, params: { criterion_id: criterion.id }, format: :json
        expect(criterion.levels.pluck(:meets_expectations).uniq).to eq([false])
      end
    end
  end
end
