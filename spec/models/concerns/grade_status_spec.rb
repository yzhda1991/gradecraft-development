describe GradeStatus do 
  let(:course) { create(:course) }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:grade) { create(:grade, assignment: assignment, student: student) }
  
  describe "graded_and_visible_by_student?" do
    it "returns true if the grade is released" do
      grade.status = "Released"
      assignment.release_necessary = true
      expect(grade.graded_and_visible_by_student?).to eq true
    end
    
    it "returns true if the grade is graded and the assignment does not need release" do 
      grade.status = "Graded"
      assignment.release_necessary = false
      expect(grade.graded_and_visible_by_student?).to eq true
    end
    
    it "returns false if the grade is not released" do
      grade.status = "Graded"
      assignment.release_necessary = true
      expect(grade.graded_and_visible_by_student?).to eq false
    end
    
    it "returns false if the grade is not marked as graded" do
      grade.status = nil
      assignment.release_necessary = true
      expect(grade.graded_and_visible_by_student?).to eq false
    end
    
    it "returns false if the grade is marked as in progress" do
      grade.status = "In Progress"
      assignment.release_necessary = true
      expect(grade.graded_and_visible_by_student?).to eq false
    end
  end
end
