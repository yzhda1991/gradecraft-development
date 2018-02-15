describe LearningObjective do
  let(:learning_objective) { create :learning_objective, :with_count_to_achieve }
  let(:category) { create :learning_objective_category }

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
    let(:student) { build :user }
    let(:cumulative_outcome) { create :learning_objective_cumulative_outcome, learning_objective: learning_objective, user: student }

    before(:each) { learning_objective.course.objectives_award_points = false }

    it "returns 'Not Started' if there is no cumulative outcome" do
      expect(learning_objective.progress student).to eq "Not Started"
    end
  end
end
