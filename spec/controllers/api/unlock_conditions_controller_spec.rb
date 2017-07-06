describe API::UnlockConditionsController do
  let!(:student)  { create(:course_membership, :student).user }
  let(:professor) { create(:course_membership, :professor).user }

  context "as a professor" do
    before do
      login_user(professor)
    end

    describe "GET index" do
      it "returns an index of conditions for a badge" do
        condition = create :unlock_condition
        #match 'api/badges/:badge_id/unlock_conditions' => 'unlock_conditions#index', :via => :get, :as => :query
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
