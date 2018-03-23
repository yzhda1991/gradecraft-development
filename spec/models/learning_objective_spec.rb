describe LearningObjective do
  let(:category) { build :learning_objective_category }
  let(:learning_objective) { build :learning_objective, :with_count_to_achieve }
  let(:cumulative_outcome) { build :learning_objective_cumulative_outcome, learning_objective: learning_objective, user: student }
  let(:learning_objective_level) { build :learning_objective_level }
  let(:student) { build :user }

  describe "validations" do
    it "require a name" do
      learning_objective.name = nil
      expect(learning_objective).to be_invalid
    end

    it "require a course" do
      learning_objective.course = nil
      expect(learning_objective).to be_invalid
    end

    it "prevent a negative value for the count to achieve" do
      learning_objective.count_to_achieve = -1
      expect(learning_objective).to be_invalid
    end

    it "ensure that the objective course matches the category course when present" do
      learning_objective.category = category
      learning_objective.course = build :course
      expect(learning_objective).to be_invalid
    end

    it "require at least a count to achieve or total points to completion value" do
      learning_objective.count_to_achieve = nil
      expect(learning_objective).to be_invalid
    end
  end

  describe "#progress" do
    before(:each) { learning_objective.course.objectives_award_points = false }

    it "returns 'Not Started' if there is no cumulative outcome" do
      expect(learning_objective.progress student).to eq "Not Started"
    end
  end

  describe "#grade_outcome_progress_for" do
    context "when the student has been assessed" do
      let(:observed_outcome) do
        create :student_visible_observed_outcome,
          cumulative_outcome: cumulative_outcome,
          learning_objective_level: learning_objective_level
      end

      it "returns 'Failed' if there are any failed observed outcomes" do
        observed_outcome
        learning_objective_level.update flagged_value: :not_proficient
        expect(learning_objective.progress student).to eq "Failed"
      end

      it "returns 'In Progress' if the count to achieve has not yet been met" do
        observed_outcome
        learning_objective.update count_to_achieve: 2
        learning_objective_level.update flagged_value: :proficient
        expect(learning_objective.progress student).to include "In Progress"
      end

      it "returns 'Completed' if the count to achieve has been met" do
        observed_outcome
        learning_objective.update count_to_achieve: 1
        learning_objective_level.update flagged_value: :proficient
        expect(learning_objective.progress student).to eq "Completed"
      end
    end

    context "when the student has not yet been assessed" do
      it "returns 'Not Started'" do
        expect(learning_objective.progress student).to eq "Not Started"
      end
    end
  end

  describe "#point_progress_for" do
    let(:course) { build :course, :uses_learning_objectives, objectives_award_points: true }
    let(:learning_objective) { build :learning_objective, :with_points_to_completion, course: course }
    let(:grade) { build :student_visible_grade, raw_points: 1000, student: student }
    let(:observed_outcome) do
      create :learning_objective_observed_outcome,
        cumulative_outcome: cumulative_outcome,
        learning_objective_level: learning_objective_level,
        grade: grade
    end

    it "returns 'Not Started' if no points have been earned yet" do
      expect(learning_objective.progress student).to eq "Not Started"
    end

    it "returns 'In Progress' if you have not yet met the points to achieve" do
      observed_outcome
      expect(learning_objective.progress student).to include "In Progress"
    end

    it "returns 'Completed' if you have met the points to achieve" do
      observed_outcome
      grade.update raw_points: 1500
      expect(learning_objective.progress student).to include "Completed"
    end
  end
end
