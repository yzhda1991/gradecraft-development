describe API::LearningObjectives::ObjectivesController do
  let(:course) { create :course, :uses_learning_objectives }
  let(:learning_objective) { build_stubbed :learning_objective, course: course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { create :user, courses: [course], role: :professor }
    let(:learning_objective_params) { attributes_for :learning_objective }

    describe "POST create" do
      it "creates a new learning objective for the course" do
        expect{ post :create, params: { learning_objective: learning_objective_params, format: :json } }.to \
          change(LearningObjective, :count).by 1
      end
    end

    describe "PUT update" do
      let(:learning_objective) { create :learning_objective, course: course }

      it "updates the learning objective" do
        learning_objective_params.merge(name: "Learn Stuff", description: "Ensure you have learned")
        put :update, params: { learning_objective: learning_objective_params.merge(name: "Learn Stuff",
          description: "Ensure you have learned something"), id: learning_objective.id }, format: :json
        expect(learning_objective.reload.name).to eq "Learn Stuff"
        expect(learning_objective.description).to eq "Ensure you have learned something"
      end
    end

    describe "DELETE destroy" do
      it "deletes the learning objective from the course" do
        learning_objective = create :learning_objective, course: course
        expect{ delete :destroy, params: { id: learning_objective.id }, format: :json }.to \
          change(LearningObjective, :count).by -1
      end
    end
  end

  context "as a student" do
    let(:user) { build :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { post :create, format: :json },
          -> { put :update, params: { id: learning_objective.id }, format: :json },
          -> { delete :destroy, params: { id: learning_objective.id }, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
