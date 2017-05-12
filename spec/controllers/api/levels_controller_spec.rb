describe API::LevelsController do
  let(:course) { build :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "creates a new level" do
        post :create, params: { level: {criterion_id: criterion.id, name: "New Level", points: 1000 }}, format: :json
        expect(criterion.levels.count).to eq(3)
        expect(assigns(:level).name).to eq("New Level")
      end
    end

    describe "PUT update" do
      let(:level) { criterion.levels.last }
      let(:params) do
        { id: level.id, level: { description: "You have reached a new level", meets_expectations: true }}
      end

      it "updates the level attributes" do
        put :update, params: params, format: :json
        expect(level.reload.description).to eq("You have reached a new level")
      end

      it "does not update meets expectations" do
        put :update, params: params, format: :json
        expect(level.reload.meets_expectations).to be_falsey
      end

      it "renders success message when request format is JSON" do
        put :update, params: params, format: :json
        expect(response.status).to eq(200)
        expect(assigns(:level)).to eq(criterion.levels.last)
      end

      describe "on error" do
        it "describes failure to update" do
          allow_any_instance_of(Level).to receive(:update_attributes) { false }
          put :update, params: params, format: :json
          expect(JSON.parse(response.body)).to eq("errors"=>[{"detail"=>"failed to update level"}], "success"=>false)
          expect(response.status).to eq(500)
        end
      end
    end

    describe "DELETE level" do
      it "removes the level from the criterion" do
        delete :destroy, params: { id: criterion.levels.last.id}, format: :json
        expect(criterion.levels.count).to eq(1)
        expect(JSON.parse(response.body)).to eq("message"=>"level successfully deleted", "success"=>true)
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    it "redirects protected routes to root" do
      [
        -> { put :update, params: { id: 144 }, format: :json}
      ].each do |protected_route|
        expect(protected_route.call).to redirect_to(:root)
      end
    end
  end
end
