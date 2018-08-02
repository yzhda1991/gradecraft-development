describe API::LearningObjectives::OutcomesController do
  let(:course) { build :course, :uses_learning_objectives }
  let(:learning_objective) { create :learning_objective, :with_linked_assignment, course: course }
  let!(:observed_outcome) { create :student_visible_observed_outcome, cumulative_outcome: cumulative_outcome }
  let(:assignment) { learning_objective.assignments.first }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an instructor" do
    let!(:cumulative_outcome) { create :learning_objective_cumulative_outcome, learning_objective: learning_objective }
    let(:user) { create :user, courses: [course], role: :professor }

    describe "#outcomes_for_assignment" do
      context "when student ids are provided" do
        it "assigns the outcomes for all objectives linked to the assignment" do
          get :outcomes_for_assignment, params: { assignment_id: assignment.id }, format: :json
          expect(assigns(:cumulative_outcomes)).to match_array [cumulative_outcome]
          expect(assigns(:observed_outcomes)).to match_array [observed_outcome]
        end
      end

      context "when no student ids are provided" do
        let(:student) { build :user }
        let!(:another_cumulative_outcome) { create :learning_objective_cumulative_outcome, learning_objective: learning_objective, user: student }

        it "assigns the filtered outcomes by student for all objectives linked to the assignment" do
          get :outcomes_for_assignment, params: { assignment_id: assignment.id, student_ids: [student.id] }, format: :json
          expect(assigns(:cumulative_outcomes)).to match_array [another_cumulative_outcome]
          expect(assigns(:observed_outcomes)).to be_empty
        end
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
    let(:user) { create :user, courses: [course], role: :student }
    let!(:cumulative_outcome) { create :learning_objective_cumulative_outcome, learning_objective: learning_objective, user: user }

    describe "#outcomes_for_assignment" do
      it "assigns the visible outcomes for only the student and objectives linked to the assignment" do
        get :outcomes_for_assignment, params: { assignment_id: assignment.id }, format: :json
        expect(assigns(:cumulative_outcomes)).to match_array [cumulative_outcome]
        expect(assigns(:observed_outcomes)).to match_array [observed_outcome]
      end
    end
  end
end
