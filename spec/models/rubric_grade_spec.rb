require "active_record_spec_helper"

describe RubricGrade do
  describe ".for_student" do
    it "returns all rubric grades for a specific student" do
      student = create(:user)
      student_grade = create(:rubric_grade, student: student)
      another_grade = create(:rubric_grade)
      results = RubricGrade.for_student(student)
      expect(results).to eq [student_grade]
    end
  end
end
