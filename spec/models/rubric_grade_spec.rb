require "active_record_spec_helper"

describe RubricGrade do
  describe ".for_course" do
    it "returns all grades for assignments that belong to a specific course" do
      course = create(:course)
      course_assignment = create(:assignment, course: course)
      course_grade = create(:rubric_grade, assignment: course_assignment)
      another_grade = create(:rubric_grade)
      results = RubricGrade.for_course(course)
      expect(results).to eq [course_grade]
    end

    it "returns all grades for submissions that belong to a specific course" do
      course = create(:course)
      course_submission = create(:submission, course: course)
      course_grade = create(:rubric_grade, assignment: nil, submission: course_submission)
      another_grade = create(:rubric_grade, assignment: nil)
      results = RubricGrade.for_course(course)
      expect(results).to eq [course_grade]
    end
  end

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
