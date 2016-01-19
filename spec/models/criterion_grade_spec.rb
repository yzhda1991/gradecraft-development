require "active_record_spec_helper"

describe CriterionGrade do

  describe "validations" do
    it "requires an assignment" do
      subject.assignment_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:assignment_id]).to include "can't be blank"
    end

    it "requires a criterion" do
      subject.criterion_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:criterion_id]).to include "can't be blank"
    end

    it "requires a student" do
      subject.student_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:student_id]).to include "can't be blank"
    end
  end

  describe ".for_course" do
    it "returns all grades for assignments that belong to a specific course" do
      course = create(:course)
      course_assignment = create(:assignment, course: course)
      course_grade = create(:criterion_grade, assignment: course_assignment)
      another_grade = create(:criterion_grade)
      results = CriterionGrade.for_course(course)
      expect(results).to eq [course_grade]
    end
  end

  describe ".for_student" do
    it "returns all rubric grades for a specific student" do
      student = create(:user)
      student_grade = create(:criterion_grade, student: student)
      another_grade = create(:criterion_grade)
      results = CriterionGrade.for_student(student)
      expect(results).to eq [student_grade]
    end
  end

  describe ".find_or_create" do
    it "finds and existing grade for assignment criterion and student" do
      world = World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade)
      results = CriterionGrade.find_or_create(world.assignment.id, world.criterion.id, world.student.id)
      expect(results).to eq world.criterion_grade
    end

    it "creates a grade for assignment and student if none exists" do
      world = World.create.with(:course, :student, :assignment, :rubric, :criterion)
      expect{ CriterionGrade.find_or_create(world.assignment.id, world.criterion.id, world.student.id) }.to change{ CriterionGrade.count }.by(1)
    end
  end
end
