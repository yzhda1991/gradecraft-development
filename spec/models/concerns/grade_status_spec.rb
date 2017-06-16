describe GradeStatus do
  let(:grade) { create :grade }
  let(:in_progress_grade) { create :in_progress_grade }
  let(:student_visible_grade) { create :student_visible_grade}


  describe "status scopes" do
    before do
      grade
      in_progress_grade
      student_visible_grade
    end

    describe ".in_progress" do
      it "returns all grades that are incomplete but modified" do
        expect(Grade.in_progress).to eq([in_progress_grade])
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
    end
  end
end
