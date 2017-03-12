describe AssignmentTypeWeight do

  let(:student) { create(:user) }
  let(:subject) { create(:assignment_type_weight, student: student) }

  context "validations" do

    it "is valid with a student, assignment, assignment_type, a weight, and course" do
      expect(subject).to be_valid
    end

    it "is invalid without a student" do
      subject.student = nil
      expect(subject).to be_invalid
    end

    it "is invalid without a weight" do
      subject.weight = nil
      expect(subject).to be_invalid
    end
  end

  describe ".for_course" do
    it "returns all assignment weights for a specific course" do
      course = create(:course)
      course_assignment_type_weight = create(:assignment_type_weight, course: course)
      another_assignment_type_weight = create(:assignment_type_weight)
      results = AssignmentTypeWeight.for_course(course)
      expect(results).to eq [course_assignment_type_weight]
    end
  end

  describe ".for_student" do
    it "returns all assignment weights for a specific student" do
      student = create(:user)
      student_assignment_type_weight = create(:assignment_type_weight, student: student)
      another_assignment_type_weight = create(:assignment_type_weight)
      results = AssignmentTypeWeight.for_student(student)
      expect(results).to eq [student_assignment_type_weight]
    end
  end
end
