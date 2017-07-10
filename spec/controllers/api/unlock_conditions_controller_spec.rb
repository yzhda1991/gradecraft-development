describe API::UnlockConditionsController do
  let!(:student)  { create(:course_membership, :student).user }
  let(:professor) { create(:course_membership, :professor).user }
  let(:assignment) { create :assignment }
  let(:badge) { create :badge }

  context "as a professor" do
    before do
      login_user(professor)
    end

    describe "GET index" do
      it "returns an index of conditions for a badge" do
        condition = create :unlock_condition
        get :index, params: { badge_id: condition.unlockable_id }, format: :json
        expect(assigns(:unlock_conditions)).to eq([condition])
      end

      it "returns an index of conditions for an assignment" do
        condition = create :unlock_condition_for_assignment
        get :index, params: { assignment_id: condition.unlockable_id }, format: :json
        expect(assigns(:unlock_conditions)).to eq([condition])
      end

      it "returns an index of conditions for a grade scheme element" do
        condition = create :unlock_condition_for_gse
        get :index, params: { grade_scheme_element_id: condition.unlockable_id }, format: :json
        expect(assigns(:unlock_conditions)).to eq([condition])
      end
    end

    describe "POST create" do
      it "creates a new unlock_condition" do
        expect{ post :create,
                params: { unlock_condition:
                  { unlockable_id: assignment.id,
                    unlockable_type: "Assignment",
                    condition_id: badge.id,
                    condition_type: "Badge",
                    condition_state: "Earned"
                  }
                }, format: :json }.to change(UnlockCondition, :count).by(1)
      end
    end

    describe "PUT update" do
      it "updates the condition with included params" do
        condition = create :unlock_condition
        params = { id: condition.id, unlock_condition: { condition_id: badge.id, condition_type: "Badge", condition_state: "Earned" }}
        put :update, params: params, format: :json
        expect(condition.reload.condition_id).to eq(badge.id)
      end
    end

    describe "DELETE destroy" do
      it "deletes the unlock condition" do
        condition = create :unlock_condition
        delete :destroy, params: { id: condition.id}, format: :json
        expect(UnlockCondition.count).to eq(0)
        expect(JSON.parse(response.body)).to eq("message"=>"unlock condition successfully deleted", "success"=>true)
      end
    end
  end

  context "as a student" do
    before do
      login_user(student)
    end

    describe "GET index" do
      it "redirects" do
        condition = create :unlock_condition
         get :index, params: { badge_id: condition.unlockable_id }, format: :json
        expect(response.status).to eq(302)
      end
    end
  end
end
