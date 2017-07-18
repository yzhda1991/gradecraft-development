describe GradeStatus do
  let(:unmodified_grade) { create :grade }
  let(:in_progress_grade) { create :in_progress_grade }
  let(:complete_grade) { create :complete_grade }
  let(:student_visible_grade) { create :student_visible_grade}


  describe "status scopes" do
    before do
      unmodified_grade
      in_progress_grade
      complete_grade
      student_visible_grade
    end

    describe ".in_progress" do
      it "returns all grades that are incomplete but modified" do
        expect(Grade.in_progress).to eq([in_progress_grade])
      end
    end

    describe ".not_released" do
      it "returns all grades that are not student visible but modified" do
        scope = Grade.not_released
        expect(scope).to include(in_progress_grade)
        expect(scope).to include(complete_grade)
        expect(scope).not_to include(unmodified_grade)
        expect(scope).not_to include(student_visible_grade)

      end
    end

    describe ".student_visible" do
      it "returns all grades that are student visible" do
        expect(Grade.student_visible).to eq([student_visible_grade])
      end
    end
  end

  describe "#in_progress?" do
    it "returns true for grades that are incomplete but modified" do
      expect(in_progress_grade.in_progress?).to be_truthy
      expect(student_visible_grade.in_progress?).to be_falsey
    end
  end

  describe "#not_released?" do
    it "returns true for grades that are modified but not student visible" do
      expect(in_progress_grade.not_released?).to be_truthy
      expect(student_visible_grade.in_progress?).to be_falsey
      expect(complete_grade.not_released?).to be_truthy
    end
  end
end
