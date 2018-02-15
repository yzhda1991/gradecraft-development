describe LearningObjectiveCategory do
  describe "validations" do
    let(:category) { build_stubbed :learning_objective_category }

    it "require a name" do
      category.name = nil
      expect(category).to be_invalid
    end

    it "require a course" do
      category.course = nil
      expect(category).to be_invalid
    end
  end
end
