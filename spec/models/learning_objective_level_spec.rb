describe LearningObjectiveLevel do
  describe "validations" do
    let(:subject) { build_stubbed :learning_objective_level }

    it "require a name" do
      subject.name = nil
      expect(subject).to be_invalid
    end

    it "require an objective" do
      subject.objective = nil
      expect(subject).to be_invalid
    end

    it "require a flagged value" do
      subject.flagged_value = nil
      expect(subject).to be_invalid
    end
  end
end
