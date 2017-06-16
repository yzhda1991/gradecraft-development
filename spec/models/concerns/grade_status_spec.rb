describe GradeStatus  , focus: true do
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment) }
  let(:grade) { create(:grade, assignment: assignment) }
  let(:challenge_grade) { create(:challenge_grade) }

  describe ".student_visible" do
    it "returns all grades that are student visible" do
      graded_grade = create :grade, complete: true, student_visible: false
      student_visible = create :grade, complete: true, student_visible: true
      assignment = create :assignment
      expect(Grade.student_visible).to eq([student_visible])
    end
  end

  describe "#is_graded?" do
    it "returns true if the challenge grade is graded" do
      challenge_grade = create(:challenge_grade, status: "Graded")
      expect(challenge_grade.is_graded?).to eq(true)
    end
    it "returns false if the challenge grade is not graded" do
      challenge_grade = create(:challenge_grade, status: nil)
      expect(challenge_grade.is_graded?).to eq(false)
    end
  end

  describe "#update_status_fields" do
    it "updates the fields on 'In Progress' grades" do
      grade.status = "In Progress"
      grade.update_status_fields
      expect(grade.complete).to be_falsey
      expect(grade.student_visible).to be_falsey
    end

    it "updates the fields on 'Graded' grades" do
      grade.status = "Graded"
      grade.update_status_fields
      expect(grade.complete).to be_truthy
      expect(grade.student_visible).to be_falsey
    end

    it "updates the fields on 'Released' grades" do
      grade.status = "Released"
      grade.update_status_fields
      expect(grade.complete).to be_truthy
      expect(grade.student_visible).to be_truthy
    end
  end
end
