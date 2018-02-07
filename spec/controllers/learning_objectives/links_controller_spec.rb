describe LearningObjectives::LinksController do
  let(:course) { build :course, :uses_learning_objectives }
  let(:user) { build_stubbed :user, courses: [course], role: :student }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  describe "GET index" do
    context "when the current course does not have learning objectives enabled" do
      it "redirects to dashboard" do
        course.update(allows_learning_objectives: false)
        get :index
        expect(response).to redirect_to dashboard_path
      end
    end

    context "when the current course has learning objectives enabled" do
      let!(:learning_objective) { create :learning_objective, course: course }

      it "returns the objectives" do
        get :index
        expect(assigns :objectives).to eq [learning_objective]
      end
    end
  end
end
