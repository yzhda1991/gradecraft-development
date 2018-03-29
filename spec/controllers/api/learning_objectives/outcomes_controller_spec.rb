describe API::LearningObjectives::OutcomesController, focus: true do
  let(:course) { create :course, :uses_learning_objectives }
  let(:learning_objective) { create :learning_objective, :with_linked_assignment, course: course }
  let(:assignment) { learning_objective.assignments.first }
  let!(:cumulative_outcome) { create :learning_objective_cumulative_outcome, learning_objective: learning_objective }
  let!(:observed_outcome) { create :learning_objective_observed_outcome, cumulative_outcome: cumulative_outcome }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an instructor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "#outcomes_for_assignment" do
      it "assigns the outcomes for all objectives linked to the assignment" do
        get :outcomes_for_assignment, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:cumulative_outcomes)).to match_array [cumulative_outcome]
        expect(assigns(:observed_outcomes)).to match_array [observed_outcome]
      end
    end

    describe "#outcomes_for_objective" do
      let(:another_objective) { build :learning_objective, course: course }
      let!(:another_cumulative_outcome) { create :learning_objective_cumulative_outcome, learning_objective: another_objective }

      context "when students ids are not provided" do
        it "assigns the outcomes for the objective" do
          get :outcomes_for_objective, params: { objective_id: learning_objective.id }, format: :json
          expect(assigns(:cumulative_outcomes)).to match_array [cumulative_outcome]
          expect(assigns(:observed_outcomes)).to match_array [observed_outcome]
        end
      end

      context "when student ids are provided" do
        let(:student) { build :user, courses: [course], role: :student }

        it "assigns the filtered outcomes for the objective" do
          cumulative_outcome.update user: student
          get :outcomes_for_objective, params: { objective_id: learning_objective.id, student_ids: [student.id] }, format: :json
          expect(assigns(:cumulative_outcomes)).to match_array [cumulative_outcome]
          expect(assigns(:observed_outcomes)).to match_array [observed_outcome]
        end
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "#outcomes_for_assignment" do
      it "assigns the visible outcomes for all objectives linked to the assignment" do
        get :outcomes_for_assignment, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:cumulative_outcomes)).to match_array [cumulative_outcome]
        expect(assigns(:observed_outcomes)).to be_empty
      end
    end
  end
end
