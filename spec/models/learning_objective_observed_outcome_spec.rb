describe LearningObjectiveObservedOutcome do
  describe "validations" do
    let(:outcome) { build_stubbed :learning_objective_observed_outcome }

    it "require an assessed at date" do
      outcome.assessed_at = nil
      expect(outcome).to be_invalid
    end

    it "require an objective level" do
      outcome.learning_objective_level = nil
      expect(outcome).to be_invalid
    end

  end
  describe ".shows_proficiency" do
    let!(:nearing_proficiency_outcome) { create :student_visible_observed_outcome, learning_objective_level: nearing_proficiency_level }
    let!(:proficient_outcome) { create :student_visible_observed_outcome, learning_objective_level: proficient_level }
    let(:nearing_proficiency_level) { create :learning_objective_level, :nearing_proficiency }
    let(:proficient_level) { create :learning_objective_level, :proficient }
    it "doesn't return results that are nearing or not proficient" do
      expect(LearningObjectiveObservedOutcome.shows_proficiency).to eq [proficient_outcome]
    end
  end
end
