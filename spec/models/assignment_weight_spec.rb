require "active_record_spec_helper"

describe AssignmentWeight do
  describe ".for_course" do
    it "returns all assignment weights for a specific course" do
      course = create(:course)
      course_assignment_weight = create(:assignment_weight, course: course)
      another_assignment_weight = create(:assignment_weight)
      results = AssignmentWeight.for_course(course)
      expect(results).to eq [course_assignment_weight]
    end
  end

  describe ".for_student" do
    it "returns all assignment weights for a specific student" do
      student = create(:user)
      student_assignment_weight = create(:assignment_weight, student: student)
      another_assignment_weight = create(:assignment_weight)
      results = AssignmentWeight.for_student(student)
      expect(results).to eq [student_assignment_weight]
    end
  end
end
