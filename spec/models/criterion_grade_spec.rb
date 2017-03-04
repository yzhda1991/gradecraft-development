require "active_record_spec_helper"

describe CriterionGrade do
  
  let(:course) { create(:course) }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }
  let(:criterion_grade) { create(:criterion_grade, assignment: assignment, criterion: criterion, student: student) }

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
      another_grade = create(:criterion_grade)
      results = CriterionGrade.for_course(course)
      expect(results).to eq [criterion_grade]
    end
  end

  describe ".for_student" do
    it "returns all rubric grades for a specific student" do
      another_grade = create(:criterion_grade)
      results = CriterionGrade.for_student(student)
      expect(results).to eq [criterion_grade]
    end
  end

  describe ".find_or_create" do
    it "finds an existing grade for assignment criterion and student" do
      criterion_grade
      expect(CriterionGrade.find_or_create(assignment.id, criterion.id, student.id)).to eq criterion_grade
    end

    it "creates a grade for assignment and student if none exists" do
      criterion_2 = create(:criterion)
      expect{ CriterionGrade.find_or_create(assignment.id, criterion_2.id, student.id) }.to change{ CriterionGrade.count }.by(1)
    end
  end
end
